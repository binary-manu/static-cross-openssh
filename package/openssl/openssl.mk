openssl/DEFAULT_VERSION := 3.3.1
define openssl/determine_latest
  $(eval override openssl/VERSION := $(call shell_checked,
    . ./version.sh;
	list_github_tags https://github.com/openssl/openssl |
	sed -En
	  -e '/^OpenSSL_1/{s/^OpenSSL_(.*)$$/\1/; y/_/./;   p}; # Matches OpenSSL 1.x versions'
	  -e '/^openssl-3/{s/^openssl-(.*)$$/\1/; /alpha/d; p}; # Matches OpenSSL 3.x versions' |
	sort_versions | tail -n 1
  ))
endef
$(call determine_version,openssl,$(openssl/DEFAULT_VERSION))

openssl/TARBALL := https://www.openssl.org/source/openssl-$(openssl/VERSION).tar.gz

openssl/dir = $(build_dir)/openssl/openssl-$(openssl/VERSION)

define openssl/build =
	+cd '$(openssl/dir)'
	./Configure --prefix="$(prefix)" --cross-compile-prefix="$(host_triplet)-" \
		no-shared no-asm linux-elf no-docs
	'$(MAKE)'
endef

define openssl/install =
	+'$(MAKE)' -C '$(openssl/dir)' install DESTDIR='$(staging_dir)'
endef
