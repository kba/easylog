easylog
=======

A wrapper around winston to simplify configuration and log beautifully.

## Table of Contents
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
  * [Log the Logging](#log-the-logging)
  * [Log Patterns](#log-patterns)
* [API](#api)
  * [node_env](#node_env)
  * [easylog_level](#easylog_level)
  * [root_dir_files](#root_dir_files)
  * [cwd](#cwd)
  * [logdir](#logdir)
  * [root_label](#root_label)
  * [override_winston](#override_winston)
  * [injected_deps](#injected_deps)
  * [injected_deps.winston](#injected_deps.winston)
  * [package_json](#package_json)
  * [config_file_candidates](#config_file_candidates)
* [Acknowledgements](#acknowledgements)

## Motivation

[Winston](https://github.com/winstonjs/winston) is an excellent logging library
that consists of easy to understand and easy to hack components. Getting
started is relatively painless and there's a plethora of transports for various
endpoints like files, console, databases, cloud services...

What winston lacks is the possiblity to configure the components without a lot
of code. I found myself copy and pasting a wrapper class that sets up nice
console formatting, sane log file locations, timer/profiling etc. I wanted a
library that would make these customizations easy and whose behavior could be
driven by one or more configuration files rather than code. `easylog` is that
library.

## Installation

```
npm install --save easylog
```

## Usage

The module generates a default logging container and exports a constructor for child loggers.

The best way to use it is to pass it the current module. This way the logger
will know for which file it logs events:

```js
/* myFile.js */
var log = require('easylog')(module)

log.info("Life, Universe &c?", {'answer', 42});
```

![](./doc/screenshots/log-42.png)

## Configuration

`easylog` can be configured by a JSON object that conforms to a JSON schema file.
By default, the configuration will be searched, in order of preference:

* A file `easylog-development.json` or `easylog-production.json`, depending on your `$NODE_ENV`
* A file `easylog.json`
* An `easylog` entry in the `package.json`

The [full schema](./doc/schema-full.json) is comprehensive but you can specify
only fragments of the configuraiton in the mentioned locations, the default
config will be computed on the fly, see
[./doc/default-config.json](./doc/default-config.json) for a static copy of the
default configuration file.


## API

### node_env

The environemnt, i.e. `development` or `production`. This overrides the
`NODE_ENV` environment variable and defaults to `development`.

### easylog_level

The log level of easylog itself. For debugging purposes, this is set to `debug`
by defualt. See [Log the Logging](#log-the-logging).

### root_dir_files
### cwd
### logdir
### root_label
### override_winston
### injected_deps
### injected_deps.winston
### package_json
### config_file_candidates