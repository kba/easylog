Change Log
==========

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

<!-- BEGIN-MARKDOWN-TOC -->
* [unreleased](#unreleased)
* [0.0.12 / 2016-07-18](#0012--2016-07-18)
	* [Fixed](#fixed)
* [0.0.10 / 2016-01-28](#0010--2016-01-28)
	* [Added](#added)
	* [Fixed](#fixed-1)
* [0.0.6 - 2016-01-07](#006---2016-01-07)
	* [Fixed](#fixed-2)
* [0.0.5 - 2016-01-07](#005---2016-01-07)
	* [Added](#added-1)
	* [Changed](#changed)
	* [Fixed](#fixed-3)
	* [Removed](#removed)
* [0.0.4 - 2015-12-25](#004---2015-12-25)
* [0.0.3 - 2015-12-22](#003---2015-12-22)
* [0.0.2 - 2015-12-22](#002---2015-12-22)
* [0.0.1 - 2015-12-22](#001---2015-12-22)

<!-- END-MARKDOWN-TOC -->

## [unreleased]
Added
Fixed
Changed
Removed

<!-- newest-changes -->
## [0.0.12] / 2016-07-18

### Fixed
  * Non-found config file no longer crashes the logger

## [0.0.10] / 2016-01-28

### Added
  * Some basic documentation
  * Improved README
  * package schema inspection tool

### Fixed
  * make tests work
  * wrong file parsed
  * reduce log level of startup messages to silly

## [0.0.6] - 2016-01-07
### Fixed
* rel2abs was in the wrong package

## [0.0.5] - 2016-01-07
### Added
* dump-config command
* improve man page
* Gitlab API support for creating repos
### Changed
* Extracted Github/Gitlab specific functionality to resp. packages
### Fixed
* Log levels
* Extended man page coverage of config defaults / commands
### Removed


## [0.0.4] - 2015-12-25
Added
* tmux-ls command
* man page
* README
* --no-local option
* --create option

Changed
* Allow no-path constructor

Fixed
* tmux attach to existing session instead of clone if possible

## [0.0.3] - 2015-12-22
Added
* --fork option to work with Github API
* option to prefer git@ over https://
* configurable clone opts
* CLI overrideable config

Fixed
* Simplified code to use $self instead of $location in general

## [0.0.2] - 2015-12-22
Added
* `show` command
* repo_dirs: simple option to look for repos in specific dirs

Changed
* Install to `~/.local/bin/`

Fixed
* Log levels

## [0.0.1] - 2015-12-22
Added
* Initial commit

<!-- link-labels -->
[0.0.12]: ../../compare/v0.0.12...v0.0.10
[0.0.10]: ../../compare/v0.0.10...v0.0.6
[0.0.6]: ../../compare/v0.0.5...v0.0.6
[0.0.5]: ../../compare/v0.0.4...v0.0.5
[0.0.4]: ../../compare/v0.0.3...v0.0.4
[0.0.3]: ../../compare/v0.0.2...v0.0.3
[0.0.2]: ../../compare/v0.0.1...v0.0.2
[0.0.1]: ../../compare/v0.0.1...HEAD
