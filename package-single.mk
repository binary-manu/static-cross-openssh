include package/$(package_name)/*.mk

.SHELLFLAGS = -e -c
.ONESHELL:

# Don't pass variable definitions like ARCH= down to
# submakes, as they may interfere with the package build system
MAKEOVERRIDES =

host_path       := $(PATH)
export PATH     := $(toolchain_dir)/bin:$(PATH)
export CPPFLAGS := -I$(staging_dir)/$(prefix)/include
export CFLAGS   := $(CPPFLAGS) -fPIC
export LDFLAGS  := -L$(staging_dir)/$(prefix)/lib

# Adjust paths
dl_dir    := $(dl_dir_noarch)/$(package_name)/$($(package_name)/VERSION)
state_dir := $(state_dir)/$(package_name)/$($(package_name)/VERSION)
build_dir := $(build_dir)/$(package_name)/$($(package_name)/VERSION)

#############################################
# Macros for specific stages
#############################################
define downloadpkg =
	mkdir -p '$(dl_dir)'
	cd '$(dl_dir)'
	if [ -n '$($1/TARBALL)' ]; then
	  curl -fvL '$($1/TARBALL)' -o '$(dl_dir)/$(notdir $($1/TARBALL))'
	fi
endef

define preparepkg =
	rm -rf '$(build_dir)/$1'
	mkdir -p '$(build_dir)/$1'
	cd '$(build_dir)/$1'
	if [ -n '$($1/TARBALL)' ]; then
	  tar -xf '$(dl_dir)/$(notdir $($1/TARBALL))' ||
	    unzip '$(dl_dir)/$(notdir $($1/TARBALL))'
	fi
	$(call depfile,$1,prepare)
endef

define buildpkg =
	$(call $1/build)
	$(call depfile,$1,build)
endef

define installpkg =
	$(call $1/install)
endef

define packagepkg =
	mkdir -p '$(bin_dir)'
	$(call $1/package)
endef

# To detect if a version has been changed in the configuration, and thus we
# need to reextract/rebuild that package and all its dependants, each package
# has a dependency file that holds a digest of the concatenation of the
# versions for all of its direct and transitive dependencies, plus the
# toolchain.

# This macro calls a script that computes the digest and is careful to only
# update the dependency file timestamp when it changes.
dep_digest = '$(SHELL)' ./update_dep_digest.sh \
	       '$(call dep_traversal,$(package_name))$(__toolchain__/VERSION)' \
	       '$(call depends,$(package_name),depdigest)'

# DFS traversal of the dependency graph 
dep_traversal = $($1/VERSION):$(foreach dep,$($1/DEPENDS),$(call dep_traversal,$(dep)))

define declarestages =
  $(eval .PHONY                           : $1 package install                                       )
  $(eval $1                               : package                                                  )
  $(eval package                          : install                          ; $(call packagepkg,$1) )
  $(eval install                          : $(call depends,$1,build)         ; $(call installpkg,$1) )
  $(eval $(call depends,$1,build)         : $(call depends,$1,prepare)       ; $(call buildpkg,$1)   )
  $(eval $(call depends,$1,prepare)       : $(dl_dir)/$(notdir $($1/TARBALL)); $(call preparepkg,$1) )
  $(eval $(dl_dir)/$(notdir $($1/TARBALL)):                                  ; $(call downloadpkg,$1))

  $(eval $(call depends,$1,prepare)       : $(call depends,$1,depdigest)                             )
  $(eval $(call depends,$1,depdigest)     ::                                 ; $(dep_digest)         )
endef

$(call declarestages,$(package_name))
