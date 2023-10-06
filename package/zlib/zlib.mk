zlib/DEFAULT_VERSION := 1.2.13
define zlib/determine_latest
  $(eval override zlib/VERSION := $(shell
    . ./version.sh;
	list_github_tags https://github.com/madler/zlib |
	sed -En 's/^v(.*)$$/\1/p' |
	sort_versions | tail -n 1
  ))
endef
$(call determine_version,zlib,$(zlib/DEFAULT_VERSION))

zlib/TARBALL := https://zlib.net/zlib-$(zlib/VERSION).tar.gz

zlib/dir = $(build_dir)/zlib/zlib-$(zlib/VERSION)

define zlib/build :=
	+cd $(zlib/dir)
	CHOST=$(host_triplet) ./configure --prefix="$(prefix)" --static
	'$(MAKE)'
endef

define zlib/install :=
	+'$(MAKE)' -C '$(zlib/dir)' install DESTDIR='$(staging_dir)'
endef
