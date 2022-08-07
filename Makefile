prefix := /system/opt/openssh
top_dir := $(PWD)
staging_dir := $(top_dir)/staging_dir
build_dir := $(top_dir)/build_dir
state_dir := $(top_dir)/state_dir
dl_dir := $(top_dir)/dl

toolchain := /opt/local/armv7-eabihf--musl--stable-2021.11-1
host_triplet := arm-buildroot-linux-musleabihf

host_path := $(PATH)
export PATH := $(toolchain)/bin:$(PATH)
export CPPFLAGS := -I$(staging_dir)/$(prefix)/include -L. -fPIC
export CFLAGS := -I$(staging_dir)/$(prefix)/include -L. -fPIC
export LDFLAGS := -L$(staging_dir)/$(prefix)/lib

.PRECIOUS: dep.%

-include package/*/*.mk

# If no package is specifies, build openssh
PACKAGES ?= openssh

#############################################
# Helpers for state files
#############################################
depends = $(notdir $(state_dir))/dep.$1.$2

define depfile =
	mkdir -p '$(state_dir)'
	touch '$(call depends,$1,$2)'
endef

#############################################
# Dynamically declare dependencies between packages
#############################################
define declaredeps =
$(eval $1: $(call depends,$1,install))
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

#############################################
# Macros for specific stages
#############################################
define downloadpkg =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)' && { [ -n '$($1/TARBALL)' -a ! -f '$(top_dir)/$(call depends,$1,download)' ] || exit 0; } && wget --quiet '$($1/TARBALL)'
	$(call depfile,$1,download)
endef

define preparepkg =
	mkdir -p '$(build_dir)/$1'
	cd '$(build_dir)/$1' && { [ -n '$($1/TARBALL)' ] || exit 0; } &&tar -xf '$(dl_dir)/$(notdir $($1/TARBALL))'
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

#############################################
# Targets
#############################################
all: $(PACKAGES)

# Import dependencies between packages and package stages
$(foreach pkg,$(PACKAGES),$(call declareonce,$(pkg)))

clean:
	rm -rf build dep.* '$(build_dir)' '$(dl_dir)' '$(state_dir)' '$(staging_dir)'
