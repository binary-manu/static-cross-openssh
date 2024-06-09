# Notes

## Actions

### Configure

* Generate a `.config` file: `make config`

### Build

* Build all packages in current config: `make`. Requires a `.config` file.

### Clean

* Clean everything incl. `.config`: `make nuke`
* Clean everything but `.config`: `make clean-all`
* Clean everything but `.config` and downloads: `make clean-build`
* Clean current config artifacts: `make clean-config`

## Structure

```
.
├── dl
│   ├── $arch
│   │   └── __toolchain__
│   │       └── $version
│   └── noarch
│       └── $package
│           └── $version
├── output
│   └── $arch
│       ├── bin
│       │   └── config
│       ├── build_dir
│       │   ├── $package
│       │   │   └── $version
│       │   └── __toolchain__
│       │       └── $version
│       ├── staging_dir
│       │   └── $prefix
│       └── state_dir
│           ├── __toolchain__
│           │   └── $version
│           └── $package
│               └── $version
└── package
    ├── openssh
    ├── openssl
    └── zlib
```
