include functions.mk

ARCH ?= armv7-eabihf

__toolchain__/DEFAULT_VERSION := 2021.11-5
define __toolchain__/determine_latest
  $(eval override __toolchain__/VERSION := $(shell . ./version.sh; list_bootlin_versions $(ARCH) | sort_versions | tail -n 1))
endef
$(call determine_version,__toolchain__,$(__toolchain__/DEFAULT_VERSION))

dl_dir := $(dl_dir)/toolchain
state_dir := $(state_dir)/toolchain
toolchain_url := https://toolchains.bootlin.com/downloads/releases/toolchains/$(ARCH)/tarballs/$(ARCH)--musl--stable-$(__toolchain__/VERSION).tar.bz2
toolchain_file := toolchain-$(ARCH).tar.bz2

.PHONY: all
.SHELLFLAGS = -e -c
.ONESHELL:


define download =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)'
	curl -L '$(toolchain_url)' -o '$(dl_dir)/$(toolchain_file)'
	$(call depfile,toolchain,download)
endef

define prepare =
	mkdir -p '$(toolchain_dir)'
	cd '$(toolchain_dir)'
	tar -xf '$(dl_dir)/$(toolchain_file)'
	$(call depfile,toolchain,prepare)
endef

#############################################
# Targets
#############################################
all: $(call depends,toolchain,prepare)

clean:
	rm -rf '$(dl_dir)' '$(toolchain_dir)' '$(state_dir)'

dirclean:
	rm -rf '$(toolchain_dir)'
	find '$(state_dir)' -type f -not -name '$(notdir $(call depends,toolchain,download))' -delete

$(call depends,toolchain,prepare): $(call depends,toolchain,download)
	$(prepare)

$(call depends,toolchain,download):
	$(download)
