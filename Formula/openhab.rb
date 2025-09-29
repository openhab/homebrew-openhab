class Openhab < Formula
  desc "openHAB - empowering the smart home"
  homepage "https://www.openhab.org/"
  url "https://github.com/openhab/openhab-distro/releases/download/5.0.1/openhab-5.0.1.tar.gz"
  version "5.0.1"
  sha256 "c71bf0af368e171cc3d58e32ba98d34405569aa787de28cd5e616edbeaf1e019"
  license "EPL-2.0"

  depends_on "openjdk@21"

  def openhab_home
    libexec
  end

  def openhab_conf
    etc/"openhab"
  end

  def openhab_runtime
    libexec/"runtime"
  end

  def openhab_userdata
    var/"openhab"
  end

  def openhab_logs
    var/"log/openhab"
  end

  # Invoked by Homebrew to install openHAB.
  #
  # Puts user-immutable stuff (artefacts like scripts, JARs, OSGi bundles) into the Homebrew Cellar.
  # This method MUST not write to user-mutable directories.
  def install
    check_running

    # Install start scripts & runtime (jars, OSGi bundles etc.)
    openhab_home.install_metafiles
    openhab_home.install "start.sh", "start_debug.sh"
    openhab_home.install "runtime"

    # Install empty add-ons folder
    openhab_home.install "addons"

    # Save default configuration & userdata for post_install
    pkgshare.install "conf", "userdata"

    # Wrapper script for launching openHAB
    (bin/"openhab").write_env_script openhab_home/"start.sh",
      OPENHAB_HOME:     openhab_home,
      OPENHAB_CONF:     openhab_conf,
      OPENHAB_RUNTIME:  openhab_runtime,
      OPENHAB_USERDATA: openhab_userdata,
      OPENHAB_LOGDIR:   openhab_logs,
      JAVA_HOME:        Formula["openjdk@21"].opt_prefix
    chmod 0755, bin/"openhab"
  end

  # Immeditately aborts Formula execution if an instance of openHAB is running.
  def check_running
    running_processes = `pgrep -f "openhab.*java"`.strip

    odie "openHAB is running! Please stop the process before continuing." unless running_processes.empty?
  end

  # Reads the version string from a given file.
  #
  # @param file [Pathname, File] the file to read the version from
  # @return [String, nil] the version string if found, otherwise nil
  def read_version(file)
    return unless file.exist?

    file.read[/^openhab-distro\s*:\s*(.*)$/, 1]&.strip
  end

  # Converts a version string into a numeric representation.
  #
  # @param version [String] the version string in the format "X.Y.Z" or "X.Y.Z-suffix"
  # @return [Integer] the numeric version calculated as (major * 10000 + minor * 100 + patch)
  def get_version_number(version)
    parts = version.split(".")
    first = parts[0].to_i
    second = parts[1].to_i
    third = parts[2].split("-")[0].to_i
    (first * 10000) + (second * 100) + third
  end

  # Runs a command from the O`$OPENHAB_RUNTIME/bin/update.lst`.
  #
  # @param command_line [String] the command to execute in the format CMD;PARAM1[;PARAM2][;PARAM3],
  #                              parameters in square brackets are optional
  def run_command(command_line)
    line = command_line.dup
    line.gsub!("$OPENHAB_USERDATA", openhab_userdata)
    line.gsub!("$OPENHAB_CONF", openhab_conf)
    line.gsub!("$OPENHAB_HOME", openhab_home)

    parts = line.split(";")
    command, param1, param2, param3 = parts

    case command
    when "DEFAULT"
      ohai "Adding '.bak' to #{param1}"
      mv(param1, "#{param1}.bak") if File.exist?(param1)
    when "DELETE"
      if File.file?(param1)
        ohai "Deleting File: #{param1}"
        rm(param1)
      end
    when "DELETEDIR"
      if Dir.exist?(param1)
        ohai "Deleting Directory: #{param1}"
        rm_r(param1)
      end
    when "MOVE"
      ohai "Moving: From #{param1} to #{param2}"
      file_dir = File.dirname(param2)
      mkdir_p(file_dir)
      mv(param1, param2)
    when "REPLACE"
      if File.file?(param3)
        ohai "Replacing: String #{param1} to #{param2} in file #{param3}"
        # Create backup
        backup_file = "#{param3}.bak"
        cp(param3, backup_file)
        # Perform replacement using regex
        text = File.read(param3).gsub(Regexp.new(param1), param2)
        File.write(param3, text)
      end
    when "NOTE"
      ohai param1
    when "ALERT"
      opoo param1
    end
  end

  # Scans the `$OPENHAB_RUNTIME/bin/update.lst` versioning list for commands
  # that are specific to the current version and the section parameter.
  #
  # @param current_version [String] the installed version (not the version that is being installed now)
  # @param section [String] the section to scan
  # @param version_message [String] the version message to print if a relevant section is found
  def scan_versioning_list(current_version, section, version_message)
    update_list_file = openhab_runtime/"bin/update.lst"
    current_version_number = get_version_number(current_version)
    return unless update_list_file.exist?

    in_section = false
    in_new_version = false

    update_list_file.each_line do |line|
      line.strip!
      next if line.empty?

      # works till here

      case line
      when "[[#{section}]]"
        in_section = true
      when /\[\[.*\]\]/
        break if in_section
      when /^\[.*\..*\..*\]$/
        if in_section
          line_version = line.match(/\[(.*)\]/)[1]
          line_version_number = get_version_number(line_version)
          if current_version_number < line_version_number
            in_new_version = true
            ohai "#{version_message} #{line_version}"
          else
            in_new_version = false
          end
        end
      else
        run_command(line) if in_section && in_new_version
      end
    end
  end

  # Removes various caches.
  #
  # This avoids Karaf issues on upgrade.
  def remove_cache
    %w[cache tmp marketplace kar].each do |d|
      dir = openhab_userdata/d
      rm_r(dir) if dir.exist?
    end
  end

  # Installs the default configuration from the distro tarvall to the configuration directory.
  #
  # This method copies all files from the tarballs `conf` directory to `$OPENHAB_CONF`.
  # - If a file already exists and is identical, it is skipped.
  # - If a file exists but is different, it is installed with a `.dist-new` extension and a warning is issued.
  def install_default_configuration
    src = pkgshare/"conf"
    src.find do |path|
      next if path.directory?

      relative = path.relative_path_from(src)
      target = openhab_conf/relative

      target.dirname.mkpath

      if target.exist?
        # File identical, skip
        next if compare_file(path, target)

        # Different file, save as .dist-new
        opoo "Installed new version of file #{target} as #{target.basename}.dist-new. Please check for changes!"
        target = target.sub_ext("#{target.extname}.dist-new")
      end

      cp(path, target)
    end
  end

  # Installs the system files from the distro tarball.
  #
  # Use this method if no system files are present, i.e. on installation.
  # Do NOT use this method if system files are already present, as it would overwrite them.
  def install_system_files
    src = pkgshare/"userdata"
    src.find do |path|
      next if path.directory?

      relative = path.relative_path_from(src)
      target = openhab_userdata/relative
      mkdir_p target.dirname
      cp(path, target)
    end
  end

  # Updates the system files from the distro tarball according to
  # the `$OPENHAB_RUNTIME/bin/userdata_sysfiles.lst` sysfiles list.
  #
  # Use this method if system files are already present, i.e. on upgrade.
  def update_system_files
    sysfiles_list = openhab_runtime/"bin/userdata_sysfiles.lst"
    return unless sysfiles_list.exist?

    openhab_etc = openhab_userdata/"etc"

    sysfiles_list.read.each_line do |line|
      file = line.strip
      next if file.empty?

      target = openhab_etc/file
      source = pkgshare/"userdata/etc"/file

      next unless source.exist?

      target.dirname.mkpath
      cp source, target
    end
  end

  # Run the openHAB JSONDB upgrade tool.
  def run_upgradetool
    return unless Dir.exist?(openhab_userdata/"jsondb")

    ohai "Starting JSON database update ..."

    env = {
      "_JAVA_OPTIONS"    => nil,
      "OPENHAB_USERDATA" => openhab_userdata,
      "OPENHAB_CONF"     => openhab_conf,
    }

    java = Formula["openjdk@21"].opt_bin/"java"
    upgradetool = openhab_runtime/"bin/upgradetool.jar"

    stdout, stderr, = Open3.capture3(env, java, "-jar", upgradetool)
    ohai stdout

    unless stderr.empty?
      ohai stderr
      opoo "Update tool failed, please check the openHAB website (www.openhab.org) for manual update instructions."
    end

    ohai "JSON database updated successfully."
  end

  # Invoked by Homebrew after installation is finished.
  #
  # Prepares user-mutable stuff (configuration, runtime data, logs) and executes post install tasks.
  # Adapted from the [openHAB Distribution update script](https://github.com/openhab/openhab-distro/blob/main/distributions/openhab/src/main/resources/bin/update)
  def post_install
    # Ensure directories exist
    openhab_conf.mkpath
    openhab_userdata.mkpath
    openhab_logs.mkpath

    current_version = read_version(openhab_userdata/"etc/version.properties")
    new_version = read_version(pkgshare/"userdata/etc/version.properties")
    is_upgrade = current_version && new_version != current_version

    scan_versioning_list current_version, "MSG", "Important notes for version" if current_version && is_upgrade
    if current_version && is_upgrade
      scan_versioning_list current_version, "PRE",
"Performing pre-update tasks for version"
    end

    # Copy default configuration & userdata
    ohai "Installing default configuration ..."
    install_default_configuration
    if openhab_userdata.children.empty?
      ohai "Installing system files ..."
      install_system_files
    else
      ohai "Updating system files ..."
      update_system_files
    end

    # Clean-up default configuration & system files
    rm_r(pkgshare)

    ohai "Clearing cache ..."
    remove_cache

    if is_upgrade && current_version
      scan_versioning_list current_version, "POST",
"Performing post-update tasks for version"
    end
    # TODO: What to do with addons file?

    run_upgradetool
  end

  service do
    run [opt_bin/"openhab"]
    keep_alive true
    working_dir opt_libexec
  end

  def caveats
    <<~EOS
      openHAB has been installed.

      Directories:
        OPENHAB_HOME:     #{openhab_home}
        OPENHAB_RUNTIME:  #{openhab_runtime}
        OPENHAB_USERDATA: #{openhab_userdata}
        OPENHAB_CONF:     #{openhab_conf}
        OPENHAB_LOGS:     #{openhab_logs}

      To run openHAB manually:
        openhab

      To run openHAB as a background service:
        brew services start openhab
    EOS
  end

  test do
    assert_path_exists openhab_runtime/"bin/karaf", "openHAB runtime is missing"
    assert_path_exists openhab_conf, "Configuration directory missing"
    assert_path_exists openhab_userdata, "Userdata directory missing"
    assert_path_exists openhab_logs, "Logs directory is missing"
  end
end
