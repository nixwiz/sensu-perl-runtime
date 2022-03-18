# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed
- Transitioned from Travis CI to Github Actions
- Replaced CentOS 8 with Rocky Linux 8 for building for RHEL 8 and derivatives
- Use test instead of [] and [[ ]] across all because Debian 9 /bin/sh is braindead

### Added
- Amazon Linux 2 support

### Removed
- CentOS 6 due to EOL

## [1.1.0] - 2022-03-17

### Changed
- Updated Perl version to 5.34.0

### Added
- NETSNMP_INSTALL option
- add File-Slurp and JSON-XS module

## [1.0.6] - 2020-01-16

### Changed
- Updated build testing to include Oracle Linux

## [1.0.5] - 2020-01-13

### Changed
- Fixed Perl build to use -Duserelocatableinc so it can be relocated

## [1.0.4] - 2020-01-09

### Changed
- Fixed Alpine build to be more in line with Ruby Runtime build

## [1.0.3] - 2020-01-08

### Changed
- More fixes for mismatched github and docker.io account names
- Fix checksum script that I messed up by removing a line I thought was unnecessary

## [1.0.2] - 2020-01-08

### Changed
- Fix problem when mismatched github and docker.io account names

## [1.0.1] - 2020-01-08

### Changed
- Some minor cosmetic changes

## [1.0.0] - 2020-01-07

### Added
- Initial release
