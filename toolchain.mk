include functions.mk

# Default toolchain URL and version
__toolchain__/DEFAULT_VERSION := 2024.02-1

# Determine the desired toolchain version to use.
define __toolchain__/determine_latest
  $(eval override __toolchain__/VERSION := $(call shell_checked,
    . ./version.sh;
    list_bootlin_versions $(arch) |
    sort_versions |
    tail -n 1
))
endef
$(call determine_version,__toolchain__,$(__toolchain__/DEFAULT_VERSION))

# Determine the extension of the archive
define __toolchain__/determine_extension
  $(eval __toolchain__/EXTENSION := $(call shell_checked,
    . ./version.sh;
    check_bootlin_extension $(arch) $(__toolchain__/VERSION)
  ))
endef
$(call __toolchain__/determine_extension)

# Update URL with the discovered version and extension
toolchain_url := https://toolchains.bootlin.com/downloads/releases/toolchains/$(arch)/tarballs/$(arch)--musl--stable-$(__toolchain__/VERSION).tar.$(__toolchain__/EXTENSION)

# Update paths to be more confortable
dl_dir    := $(dl_dir)/__toolchain__/$(__toolchain__/VERSION)
build_dir := $(build_dir)/__toolchain__/$(__toolchain__/VERSION)
state_dir := $(state_dir)/__toolchain__/$(__toolchain__/VERSION)
toolchain_file := __toolchain__-$(arch)-$(__toolchain__/VERSION).tar.$(__toolchain__/EXTENSION)

.PHONY: all config
.SHELLFLAGS = -e -c
.ONESHELL:

define download =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)'
	curl -L '$(toolchain_url)' -o '$(dl_dir)/$(toolchain_file)'
endef

define prepare =
	mkdir -p '$(build_dir)'
	cd '$(build_dir)'
	tar -xf '$(dl_dir)/$(toolchain_file)'
	$(call depfile,toolchain,prepare)
endef

#############################################
# Targets
#############################################
all: $(call depends,toolchain,prepare)

$(call depends,toolchain,prepare): $(dl_dir)/$(toolchain_file)
	$(prepare)

$(dl_dir)/$(toolchain_file):
	$(download)

config:
	[ -z '$(__toolchain__/VERSION)' ] && { echo "__toolchain__/VERSION is empty" >&2; exit 1; }
	printf 'export %s := %s\n' '__toolchain__/VERSION' \
	   '$(__toolchain__/VERSION)' >> '$(config_file)'
