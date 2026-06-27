class OpenhabCli < Formula
  desc "Homebrewed CLI for openHAB - Empowering the smart home"
  homepage "https://www.openhab.org/"
  url "https://github.com/openhab/homebrew-openhab/archive/refs/tags/cli-v0.3.tar.gz"
  sha256 "b3e5e09626bcbadfcc118a9fd8df8840ebbaadca2a0ad453b1514e114bb82105"
  license "EPL-2.0"

  def install
    bin.install "Bin/openhab-cli" => "openhab-cli"
    chmod 0755, bin/"openhab-cli"
  end

  test do
    assert_path_exists bin/"openhab-cli", "openHAB CLI tool missing"
  end
end
