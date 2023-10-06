# static-cross-openssh: statically cross-compile sshd and sftp-server

This project means to be an easy way to rapidly build cross-compiled,
static executables for the openssh server and its SFTP subsystem. They
can then be used to get ssh access on devices such as embedded Linux
systems or Android phones, without depending on larger toolkits like
Termux. On rooted Android devices, it is easy to set up sshd to get root
access to the whole filesystem from another device using an SFTP client.

The goal here is simplicity, which takes precedence over performance and
security. It is assumed that the built service will run as root and that
will by started by the user, only when needed. It's not meant to replace
properly built SSH apps or packages, just to be a way out when you need
an SSH for some exotic device for occasional use.

## Credits due

I was looking for a way to statically build OpenSSH, and found [this
script][original-script].

It worked well, but it didn't support cross compilation. Also, it would
redownload stuff everytime it was run. So I turned it into a set of
Makefiles to take advantage of its dependency tracking, then added
cross-compilation support by automatically downloading ready-made
toolchains from [bootlin][bootlin-toolchains].

Ideas for the Makefiles come from the OpenWRT build system, in a
brutally simplified form.

## Usage

### Basic

To start a build, just enter the directory and run:

```bash
make [ARCH=<target-arch>] [PREFIX=<prefix>]
```

`ARCH` is the name of an architecture for which bootlin provides a
toolchain. For example, to compile a 32-bit ARM executable, you'd set
`ARCH` to `armv7-eabihf`, as can be seen from the linked page. This is
totally unrelated to the target triplet appended before cross-tools
inside the toolchain. The downloaded archive is the stable version using
`musl` as the C library. If not specified, the toolchain for
`armv7-eabihf` will be downloaded.

`PREFIX` is the installation prefix of the tool, that will be passed to
configuration script (i.e. `./configure --prefix="..."`). The default is
`/system/opt/openssh`.

### Version selection

Makefiles come with default versions for packages, which have been tested to
compile.  In order to avoid frequent updates to track upstream releases, a new
mode has been implemented which allows some (or all) packages, plus the
toolchain, to be built from the latest upstream versions.

For each of the packages:

* `zlib`
* `openssh`
* `openssl`
* `__toolchain__` (this is not a package name, it's used as a placeholder to refer
  to the toolchain)

one can set the variable `xxx/VERSION` (where `xxx` is one of the items above) in the
following ways:

* keep it undefined: the default version for the package will be used, just as before;
* define it to an empty string: requests the latest upstream version to be used;
* define it to a non-empty string: override the default and use this version.

For the expected common case of using the latest versions of _all_ components,
the special variable `__all__/VERSION` shall be defined to `latest`. This
triggers the makefiles to just grab all the latest and greatest versions.

Examples:

```bash
# Override zlib version, but use the defaults for the rest
make zlib/VERSION=1.2.3
# Override the toolchain version, use the defaults for all packages
make __toolchain__/VERSION=2022.05-1
# Use the latest toolchain and openssh
make __toolchain__/VERSION= openssh/VERSION=
# Use the latest versions for packages and the toolchain
make __all__/VERSION=latest
```

## Limitations

* The makefiles have no support for patching packages. The assumption
  is that downloaded packages will compile as-is. If you explicitly
  modify a file inside a package build folder and run `make` again, it
  won't rebuild the package because it uses a separate dependency file
  to track that the build has already been done.
* Changing the toolchain requires deleting the current one and
  downloading the new one.
* OpenSSL is currently built without assembly optimizations.

## Requirements

On the host, you'll need:

* GNU Make
* GNU autotools (for autoreconf)
* wget

## Make targets

* `all`: the default, downloads the toolchain, the packages sources,
builds them and prepares a tarball with the static sshd binaries under
`$PWD/bin`;
* `clean`: deletes everything
* `dirclean`: like `clean`, but preserves downloaded sources and
  the toolchain
* `switch-toolchain`: like `dirclean`, but also deletes the toolchain.
  This should be used to prepare the environment before building for a
  different architecture, so that tarballs for package sources are
  kept, but the toolchain is deleted.


## Examples

```bash
# Default armv7 build
make -j$(nproc)
mv bin/* ~/my-static-ssh/armv7/

# Clean the environment and build for x86-64
make switch-toolchain
make -j$(nproc) ARCH=x86-64 PREFIX=/usr/local
mv bin/* ~/my-static-ssh/x86-64/
```

## Install under Android

If you need to install sshd on Android, the defaults should be good
enough as the armv7 build will also work on 64 bit devices. To install
it, follow these instructions (with appropriate modifications required by
your device, if any):

* remount the system partition read-write;
* cd to `/`, then extract the tarball with the binaries. This will
  install stuff under `/system/opt/openssh`;
* create a basic `/etc/passwd` file to make `sshd` happy when it looks
  for user homes and shells. Note that, for simplicity, we'll use
    `/system/opt/openssh/etc` as the root user's home:

  ```bash
  echo 'root:x:0:0:root:/system/opt/openssh/etc:/system/bin/sh' >> /etc/passwd
  ```
* generate new host keys for your device and copy them under
  `/system/opt/openssh/etc`;
* finally, upload your public keys to
  `/system/opt/openssh/etc/.ssh/authorized_keys`;
* remount the system partition read-only;
* enjoy!

[original-script]: https://gist.github.com/fumiyas/b4aaee83e113e061d1ee8ab95b35608b
[bootlin-toolchains]: https://toolchains.bootlin.com/

<!-- vi: set et sw=2 sts=-1 ts=2 smartindent fo=tcroqna tw=72 : -->
