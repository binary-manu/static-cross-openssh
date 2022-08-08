ifneq "$(shell [ -d '$(toolchain_dir)/bin' ] && echo 1)" "1"
  toolchain_dir := $(wildcard $(toolchain_dir)/*)
endif

host_triplet := $(subst -gcc,,$(firstword $(notdir $(wildcard $(toolchain_dir)/bin/*-gcc))))

host_path := $(PATH)
PREFIX ?= /system/opt/openssh
prefix := $(PREFIX)
export PATH := $(toolchain_dir)/bin:$(PATH)
export CPPFLAGS := -I$(staging_dir)/$(prefix)/include -L. -fPIC
export CFLAGS := -I$(staging_dir)/$(prefix)/include -L. -fPIC
export LDFLAGS := -L$(staging_dir)/$(prefix)/lib

.PHONY: all
-include package/*/*.mk

# If no package is specifies, build openssh
PACKAGES ?= openssh

include functions.mk

#############################################
# Dynamically declare dependencies between packages
#############################################
define declaredeps =
$(eval .PHONY: $1)
$(eval $1: $(call depends,$1,package))
$(eval $(call depends,$1,package) : $(call depends,$1,install) ; $(call packagepkg,$1) )
$(eval $(call depends,$1,install) : $(call depends,$1,build)   ; $(call installpkg,$1) )
$(eval $(call depends,$1,build)   : $(call depends,$1,prepare) ; $(call buildpkg,$1)   )
$(eval $(call depends,$1,prepare) : $(call depends,$1,download); $(call preparepkg,$1) )
$(eval $(call depends,$1,download):                            ; $(call downloadpkg,$1))

$(eval $(call depends,$1,build)   : $(foreach dep,$($1/DEPENDS),$(call depends,$(dep),install)))
$(foreach dep,$($1/DEPENDS),$(call declareonce,$(dep)))
endef

define declareonce =
$(if $($1_done),,$(call declaredeps,$1) $(eval $1_done=1))
endef

.SHELLFLAGS = -e -c
.ONESHELL:

#############################################
# Macros for specific stages
#############################################
define downloadpkg =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)'
	if [ -n '$($1/TARBALL)' ] && \
			[ ! -f '$(top_dir)/$(call depends,$1,download)' ]; then
		wget --quiet '$($1/TARBALL)'
	fi
	$(call depfile,$1,download)
endef

define preparepkg =
	mkdir -p '$(build_dir)/$1'
	cd '$(build_dir)/$1'
	if [ -n '$($1/TARBALL)' ]; then
		tar -xf '$(dl_dir)/$(notdir $($1/TARBALL))'
	fi
	$(call depfile,$1,prepare)
endef

define buildpkg =
	$(call $1/build)
	$(call depfile,$1,build)
endef

define installpkg =
	$(call $1/install)
	$(call depfile,$1,install)
endef

define packagepkg =
	mkdir -p '$(bin_dir)'
	$(call $1/package)
	$(call depfile,$1,package)
endef

#############################################
# Targets
#############################################
all: $(PACKAGES)

# Import dependencies between packages and package stages
$(foreach pkg,$(PACKAGES),$(call declareonce,$(pkg)))
