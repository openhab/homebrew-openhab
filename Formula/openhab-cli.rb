class OpenhabCli < Formula
  desc "Homebrewed CLI for openHAB - Empowering the smart home"
  homepage "https://www.openhab.org/"
  url "https://github.com/openhab/homebrew-openhab/archive/refs/tags/cli-v0.2.tar.gz"
  sha256 "596f6bce7c7ce7e656ec67614ca67dd862af91c1274a6dee032f7ae75fbf5785"
  license "EPL-2.0"

  def install
    bin.install "Bin/openhab-cli" => "openhab-cli"
    chmod 0755, bin/"openhab-cli"
  end

  test do
    assert_path_exists bin/"openhab-cli", "openHAB CLI tool missing"
  end
end
