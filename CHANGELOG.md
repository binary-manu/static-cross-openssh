# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For versions that have a major of 0, a convention is followed so that
the minor number is incremented when backward-incompatible changes are
made, while the third number is incremented for backward compatible
changes. For example, versions `0.2.x` are not compatible with `0.1.x`.

## [Unreleased]

## [0.2.4] - 2025-05-01

### Changed

* Binaries are now built weekly.
* Use Ubuntu 24.04 for CI actions.
* Update package versions

## [0.2.3] - 2024-09-28

### Changed

* Binaries are now hosted on GitHub as artifacts.

## [0.2.2] - 2024-09-15

### Fixed

* The download URL of OpenSSL source tarballs has been updated. The old
  one no longer works.

## [0.2.1] - 2024-08-15

### Added

* A new tunable `SHRINK` controls the ability to create smaller builds,
  trading some non-essential features or runtime performance for much
  smaller files.

## [0.2.0] - 2024-07-14

### Changed

* Many things: it's major rewrite. Here's a few.
* Updated default package versions.
* Before building, a configuration file must be produced by using `make
  config` or by copying an existing one.
* It is no longer necessary to delete the toolchain to switch to a
  different architecture.
* Better directory tree organization to support multi-architecture.

### Added

* Side-by-side multi-architecture support. You can build for an
  architecture without deleting the toolchains or artifacts for others.
* Real dependency tracking among package versions: if a package version
  is changed in the configuration file, it is not necessary to rebuild
  everything: only that package and its dependant will be rebuilt.
  Changing the toolchain forces a full rebuild. Changes to the prefix
  are currently not tracked.
* Configuration files are copied alongside binaries so that they work as
  a "bill of material" of sources used for the build. They can be used
  to remake that exact build.

## [0.1.4] - 2023-10-06

### Added

* Implemented a mechanism to control versions of packages and the
  toolchain without editing the makefiles. It is also possible to use
  the latest versions for all components. Note that, for OpenSSL, the
  _latest_ version means 3.x, while the default version in the makefile
  has been kept to 1.x for now.

## [0.1.3] - 2023-08-11

### Changed

* Updated openssl to 1.1.1v
* Updated openssh to 9.4

## [0.1.2] - 2023-06-15

### Changed

* Updated zlib to 1.2.13
* Updated openssl to 1.1.1u
* Updated openssh to 9.3

## [0.1.1] - 2022-08-16

### Fixed

* Quote expansions of `$(MAKE)` in recipes.
* Properly place `+` markers on the first recipe line when using
  `.ONESHELL`.

## [0.1.0] - 2022-08-11

### Added

* Initial release.

<!-- vi: set tw=72 et sw=2 fo=tcroqan autoindent: -->
