# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For versions that have a major of 0, a convention is followed so that
the minor number is incremented when backward-incompatible changes are
made, while the third number is incremented for backward compatible
changes. For example, versions `0.2.x` are not compatible with `0.1.x`.

## [Unreleased] 

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
