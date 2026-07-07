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

For macOS, refer to the [openHAB Documentation](https://next.openhab.org/docs/installation/macos.html#package-installation).

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
