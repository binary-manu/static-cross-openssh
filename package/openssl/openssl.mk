openssl/VERSION := 1.1.1u
openssl/TARBALL := https://www.openssl.org/source/openssl-$(openssl/VERSION).tar.gz

openssl/dir = $(build_dir)/openssl/openssl-$(openssl/VERSION)

define openssl/build :=
	+cd '$(openssl/dir)'
	./Configure --prefix="$(prefix)" --cross-compile-prefix="$(host_triplet)-" \
		no-shared no-asm linux-elf
	'$(MAKE)'
endef

define openssl/install :=
	+'$(MAKE)' -C '$(openssl/dir)' install DESTDIR='$(staging_dir)'
endef
