class OpenhabCli < Formula
  desc "Homebrewed CLI for openHAB - Empowering the smart home"
  homepage "https://www.openhab.org/"
  url "https://github.com/openhab/homebrew-openhab/archive/refs/tags/cli-v0.1.tar.gz"
  sha256 "4318fabe84d4244dc7ad1dab51d85f1723138cb76591acfa452fea6a6227c1e8"
  license "EPL-2.0"

  def install
    bin.install "Bin/openhab-cli" => "openhab-cli"
    chmod 0755, bin/"openhab-cli"
  end

  test do
    assert_path_exists bin/"openhab-cli", "openHAB CLI tool missing"
  end
end
