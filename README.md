# openHAB Homebrew Tap

<img align="right" width="220" src="logo.svg" alt="Homebrewed openHAB logo" />

[![CI Build](https://github.com/openhab/homebrew-openhab/actions/workflows/build.yml/badge.svg)](https://github.com/openhab/homebrew-openhab/actions/workflows/build.yml)
[![EPL-2.0](https://img.shields.io/badge/license-EPL%202-green.svg)](https://opensource.org/licenses/EPL-2.0)

This repository provides Homebrew formulae to install openHAB with the [Homebrew Package Manager](https://brew.sh) on macOS (and Linux).

For information about the general openHAB package, please visit the [openhab-distro GitHub repo](https://github.com/openhab/openhab-distro).
For general information about openHAB, please visit the [openHAB homepage](https://www.openhab.org).

## Usage

### Installing openHAB

If you are on Linux, it is recommended to use the APT or RPM packages, as APT and RPM are way more sophisticated than our Homebrew formulae.

Add the `openhab/openhab` tap to Homebrew:

```shell
brew tap openhab/openhab
```

Next, install a version of openHAB:

```shell
# openHAB stable:
brew install openhab
# openHAB milestone:
brew install openhab-milestone
```

The `openhab`/`openhab-milestone` formulae automatically installs the `openhab-cli` tool and OpenJDK as JRE.
It is recommended to pin the openHAB formula version, as openHAB upgrades can potentially include breaking changes:

```shell
# openHAB stable:
brew pin openhab
# openHAB milestone:
brew pin openhab-milestone
```

On macOS, the OpenJDK formula version should be pinned as well, because after a OpenJDK upgrade, the Local Network Access permission needs to be granted again through _Settings_ -> _Privacy & Security_ -> _Local Network_:

```shell
brew pin openjdk@21
```

Information about the formula, e.g. how to enable the service, can be retrieved with `brew info openhab` resp. `brew info openhab-milestone`.

#### Installing a previous version

To install a previous stable version, you can check out the tagged version of the tap (example for openHAB 5.0):

```shell
git -C $(brew --prefix)/Library/Taps/openhab/homebrew-openhab checkout v5.0 Formula/openhab.rb
```

To switch back to the HEAD of the tap (i.e. current stable or milestone), you can run:

```shell
git -C $(brew --prefix)/Library/Taps/openhab/homebrew-openhab checkout main && git -C $(brew --prefix)/Library/Taps/openhab/homebrew-openhab pull
```

### Running as a service

As mentioned by `brew info openhab` resp. `brew info openhab-milestone`, you can enable the service with `brew services start openhab` resp. `brew services start openhab-milestone`.
This starts the service formula immediately and registers it to launch at login (or boot).

### openHAB CLI

The openHAB CLI tool known from the Deb/Rpm packages is also available via Homebrew:

```shell
$ openhab-cli

Usage:  openhab-cli command [options]

Possible commands:
  backup [--full] [filename]   -- Stores the current configuration of openHAB.
  clean-cache                  -- Cleans the openHAB temporary folders.
  console                      -- Opens the openHAB console.
  info                         -- Displays distribution information.
  restore [--textconfig] [--uiconfig] filename
                               -- Restores openHAB configuration from a backup.
  showlogs                     -- Displays the log messages of openHAB.
  start [--debug]              -- Starts openHAB in the terminal.
  status                       -- Checks to see if openHAB is running.
  stop                         -- Stops any running instance of openHAB.
```

### Troubleshooting

#### Apache Felix File Install

```text
... [WARN ] [org.apache.felix.fileinstall] - /usr/share/openhab/addons does not exist, please create it.
... [ERROR] [org.apache.felix.fileinstall] - Cannot create folder /var/lib/openhab/tmp/bundles. Is the folder write-protected?
```

When observing log messages like the above on startup, ensure proper `felix.fileinstall.dir` and `felix.fileinstall.dir` are set in `/opt/homebrew/var/lib/openhab/config/org/apache/felix/fileinstall/*.config`.

## Documentation

- [openHAB](https://www.openhab.org/docs)
- Homebrew: `brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh)
- Homebrew Formula: Check the [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
