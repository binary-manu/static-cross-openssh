# Shell test: must support pipefail
_ := $(shell set -o pipefail)
ifneq "$(.SHELLSTATUS)" "0"
  $(error Your shell $(SHELL) does not support pipefail)
endif

.PHONY: all toolchain packages config \
	nuke clean-all clean-build clean-config clean-arch

export top_dir     := $(PWD)
export config_file := $(top_dir)/.config

# Configuration items, default values
export arch   := armv7-eabihf
export prefix := /system/opt/openssh
export shrink := SHRINK_LEVEL_NONE

# Need this for SHRINK_LEVEL_* definitions
include functions.mk

goals_needing_config := all toolchain packages clean-config clean-arch

ifeq "$(filter config,$(MAKECMDGOALS))" ""
    # Not configuring
    # Empty == all
    ifeq "$(MAKECMDGOALS)" ""
	MAKECMDGOALS := all
    endif
    ifneq "$(filter $(goals_needing_config),$(MAKECMDGOALS))" ""
        include .config
    endif
else
    # Configuring, we need a configuration name. Use the default
    # if none is provided. No other goals can go together with
    # config.
    arch   := $(or $(ARCH),$(arch))
    prefix := $(or $(PREFIX),$(prefix))
    shrink := $(if $($(SHRINK)),$(SHRINK),$(shrink))

    ifneq "$(filter-out config,$(MAKECMDGOALS))" ""
        $(error The config target must be used on its own)
    endif
endif

export dl_root       := $(top_dir)/dl
export output_dir    := $(top_dir)/output
export config_dir    := $(output_dir)/$(arch)
export staging_dir   := $(config_dir)/staging_dir
export build_dir     := $(config_dir)/build_dir
export toolchain_dir := $(build_dir)/__toolchain__/$(__toolchain__/VERSION)
export state_dir     := $(config_dir)/state_dir
export bin_dir       := $(config_dir)/bin
export dl_dir        := $(dl_root)/$(arch)
export dl_dir_noarch := $(dl_root)/noarch

# Build all packages and then copy the configuration
# used for the build.
all: packages
	cp $(config_file) $(bin_dir)/config

packages: toolchain
	# Always clean the staging area before a build, so that
	# it is not necessary to track what is already present
	# there in case of a config change. Packages will be
	# reinstalled at each run, but not rebuilt.
	rm -rf '$(staging_dir)'
	'$(MAKE)' -f package.mk

toolchain:
	'$(MAKE)' -f toolchain.mk

config: $(config_file)

$(config_file)::
	printf 'export %s := %s\n' 'arch' '$(arch)' > '$(config_file)'
	printf 'export %s := %s\n' 'prefix' '$(prefix)' >> '$(config_file)'
	printf 'export %s := %s\n' 'shrink' '$(shrink)' >> '$(config_file)'
	'$(MAKE)' -f toolchain.mk config
	'$(MAKE)' -f package.mk config

nuke: clean-all
	rm -f '$(config_file)'

clean-all: clean-build
	rm -rf '$(dl_root)'

clean-build:
	rm -rf '$(output_dir)'

clean-config:
	rm -rf '$(config_dir)'

clean-arch:
	rm -rf '$(dl_dir)'
	rm -rf '$(config_dir)'
