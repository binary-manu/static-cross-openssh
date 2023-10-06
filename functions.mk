depends = $(subst $(top_dir),./,$(state_dir))/dep.$1.$2

define depfile =
	mkdir -p '$(state_dir)'
	touch '$(top_dir)/$(call depends,$1,$2)'
endef

# Functions for detecting the version to use for a package component
# Users should only use determine_version, which takes two arguments,
# the name of a package or component (PKG), and its default version (DF),
# and applies the following algorithm:
#   - if $(PKG)/VERSION is undefined, use the default version $(DF)
#   - Otherwise, if $(PKG)/VERSION is defined but empty, try to deterine the
#     latest available verison of the package. To to this, $(PKG)/determine_latest
#     is invoked if defined, otherwise an error is raised.
#   - Otherwise, this means $(PKG)/VERSION is defined and not empty: its value is
#      used to force a specific version
# Once a version has been picked, the variable $(PKG)/VERSION is defined (or overridden)
# to use such value.
# If the special variable __all__/VERSION is defined to latest, this is an hint
# to disregard package-specifc versions and use the latest one for all of them.
determine_latest = $(if $(subst undefined,,$(origin $1/determine_latest)),$(call $1/determine_latest),$(error $1/determine_latest is not defined))
determine_helper = $(if $($1/VERSION),,$(call determine_latest,$1))
ifeq "$(__all__/VERSION)" "latest"
  determine_version = $(call determine_latest,$1)
else
  determine_version = $(if $(subst undefined,,$(origin $1/VERSION)),$(call determine_helper,$1),$(eval $1/VERSION := $2))
endif