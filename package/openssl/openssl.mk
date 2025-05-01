openssl/DEFAULT_VERSION := 3.5.0
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

openssl/TARBALL := https://github.com/openssl/openssl/releases/download/openssl-$(openssl/VERSION)/openssl-$(openssl/VERSION).tar.gz

openssl/dir = $(build_dir)/openssl/openssl-$(openssl/VERSION)

ifeq "$(call shrink_level_at_least,$(SHRINK_LEVEL_BUILD))" "1"
openssl/shrink_opts = \
  --api=1.1.1 \
  -DOPENSSL_SMALL_FOOTPRINT \
  -Os \
  no-acvp-tests \
  no-afalgeng \
  no-apps \
  no-argon2 \
  no-aria \
  no-asan \
  no-bf \
  no-blake2 \
  no-brotli \
  no-brotli-dynamic \
  no-buildtest-c++ \
  no-cached-fetch \
  no-camellia \
  no-capieng \
  no-winstore \
  no-cast \
  no-chacha \
  no-cmac \
  no-cmp \
  no-cms \
  no-comp \
  no-crypto-mdebug \
  no-ct \
  no-deprecated \
  no-des \
  no-devcryptoeng \
  no-dgram \
  no-dso \
  no-dtls \
  no-dynamic-engine \
  no-ecx \
  no-egd \
  no-engine \
  no-external-tests \
  no-fips \
  no-fips-securitychecks \
  no-fuzz-afl \
  no-fuzz-libfuzzer \
  no-gost \
  no-http \
  no-idea \
  no-ktls \
  no-legacy \
  no-loadereng \
  no-makedepend \
  no-md2 \
  no-md4 \
  no-mdc2 \
  no-module \
  no-msan \
  no-multiblock \
  no-nextprotoneg \
  no-ocb \
  no-ocsp \
  no-padlockeng \
  no-pic \
  no-pinshared \
  no-quic \
  no-unstable-qlog \
  no-rc2 \
  no-rc4 \
  no-rc5 \
  no-rdrand \
  no-rfc3779 \
  no-rmd160 \
  no-scrypt \
  no-sctp \
  no-seed \
  no-siphash \
  no-siv \
  no-sm2 \
  no-sm2-precomp \
  no-sm3 \
  no-sm4 \
  no-sock \
  no-srp \
  no-srtp \
  no-ssl \
  no-ssl-trace \
  no-static-engine \
  no-tests \
  no-tfo \
  no-tls \
  no-ts \
  no-ubsan \
  no-ui-console \
  no-unit-test \
  no-uplink \
  no-weak-ssl-ciphers \
  no-whirlpool \
  no-zlib \
  no-zlib-dynamic \
  no-zstd \
  no-zstd-dynamic
endif

define openssl/build =
	+cd '$(openssl/dir)'
	./Configure \
	  --cross-compile-prefix="$(host_triplet)-" \
	  --prefix="$(prefix)" \
	  linux-elf \
	  no-asm \
	  no-docs \
	  no-shared \
	  $(openssl/shrink_opts)

	'$(MAKE)'
endef

define openssl/install =
	+'$(MAKE)' -C '$(openssl/dir)' install DESTDIR='$(staging_dir)'
endef
