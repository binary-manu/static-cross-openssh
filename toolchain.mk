ARCH ?= armv7-eabihf

dl_dir := $(dl_dir)/toolchain
state_dir := $(state_dir)/toolchain
toolchain_url := https://toolchains.bootlin.com/downloads/releases/toolchains/$(ARCH)/tarballs/$(ARCH)--musl--stable-2021.11-1.tar.bz2
toolchain_file := $(notdir $(toolchain_url))

.PHONY: all
.SHELLFLAGS = -e -c
.ONESHELL:

include functions.mk

define download =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)'
	wget -r '$(toolchain_url)'
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
