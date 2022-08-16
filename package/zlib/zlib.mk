zlib/VERSION := 1.2.12
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
