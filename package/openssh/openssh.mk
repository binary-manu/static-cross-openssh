openssh/VERSION := V_9_0_P1
openssh/TARBALL := https://github.com/openssh/openssh-portable/archive/refs/tags/$(openssh/VERSION).tar.gz
openssh/DEPENDS := zlib openssl

openssh/dir := $(build_dir)/openssh/openssh-portable-$(openssh/VERSION)
openssh/bin := $(bin_dir)/openssh-$(openssh/VERSION).tgz
openssh/binfiles := sbin/sshd libexec/sftp-server
openssh/conffiles := etc/sshd_config
openssh/emptydir := var/empty

define openssh/build :=
	cd $(openssh/dir)
	env PATH='$(host_path)' autoreconf -i
	./configure LDFLAGS="-static $(LDFLAGS)" LIBS="-lpthread" \
		--prefix="$(prefix)" --host="$(host_triplet)" --disable-strip \
		--with-privsep-user=root --with-privsep-path=$(prefix)/var/empty
	+'$(MAKE)'
endef

define openssh/install :=
	+'$(MAKE)' -C '$(openssh/dir)' install-nokeys DESTDIR='$(staging_dir)'
endef

define openssh/package :=
	cd '$(staging_dir)/$(prefix)'
	echo $(openssh/binfiles) | xargs -n1 $(host_triplet)-strip -s
	tar -czf $(openssh/bin) --transform 's|^|$(shell echo '$(prefix)' | sed 's|^/*||')/|' \
		--owner=root:0 --group=root:0 \
		$(openssh/binfiles) $(openssh/conffiles) \
		$(openssh/emptydir)
endef
