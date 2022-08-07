openssh/VERSION := V_8_5_P1
openssh/TARBALL := https://github.com/openssh/openssh-portable/archive/refs/tags/$(openssh/VERSION).tar.gz
openssh/DEPENDS := zlib openssl

openssh/dir = $(build_dir)/openssh/openssh-portable-$(openssh/VERSION)

define openssh/build :=
	cd $(openssh/dir) && \
  env PATH='$(host_path)' autoreconf -i && \
	./configure LDFLAGS="-static $(LDFLAGS)" LIBS="-lpthread" \
		--prefix="$(prefix)" --host="$(host_triplet)" --disable-strip \
		--with-privsep-user=root --with-privsep-path=$(prefix)/var/empty
	+'$(MAKE)' -C '$(openssh/dir)'
endef

define openssh/install :=
	+'$(MAKE)' -C '$(openssh/dir)' install-nokeys DESTDIR='$(staging_dir)'
endef
