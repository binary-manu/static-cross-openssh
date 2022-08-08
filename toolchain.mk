ARCH ?= armv7-eabihf

toolchain_url := https://toolchains.bootlin.com/downloads/releases/toolchains/$(ARCH)/tarballs/$(ARCH)--musl--stable-2021.11-1.tar.bz2
toolchain_file := $(notdir $(toolchain_url))

.PHONY: all
.SHELLFLAGS = -e -c
.ONESHELL:

include functions.mk

define download =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)'
	if [ ! -f '$(top_dir)/$(call depends,toolchain,download)' ]; then
		wget --quiet '$(toolchain_url)'
	fi
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

$(call depends,toolchain,prepare): $(call depends,toolchain,download)
	$(prepare)

$(call depends,toolchain,download):
	$(download)
