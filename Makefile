ZLIB_VERSION := 1.2.12
OPENSSL_VERSION := 1.1.1k
OPENSSH_VERSION := V_8_5_P1

prefix := /system/opt/openssh
top := $(PWD)
root := $(top)/root
build := $(top)/build
dist = $(top)/dist

export CPPFLAGS := -I$(root)/include -L. -fPIC
export CFLAGS := -I$(root)/include -L. -fPIC
export LDFLAGS := -L$(root)/lib

toolchain := /opt/local/armv7-eabihf--musl--stable-2021.11-1
host := arm-buildroot-linux-musleabihf
oldpath := $(PATH)
export PATH := $(toolchain)/bin:$(PATH)
export MAKEFLAGS := -j$(shell nproc)

.PHONY: all zlib clean openssh openssl

define depFile
	$(top)/.dep.$1.$2
endef


all: tarball

clean:
	rm -rf build dist root deploy .dep.* *.tgz

tarball: openssh-armv7-linux-musleabi-static.tgz

openssh-armv7-linux-musleabi-static.tgz: openssh
	cd deploy && \
	tar -czf ../openssh-armv7-linux-musleabi-static.tgz --owner=root --group=root *

zlib: $(call depFile,zlib,built)

$(call depFile,zlib,built): $(call depFile,zlib,prepared)
	cd $(build)/zlib* && \
	CHOST=$(host) ./configure --prefix="$(root)" --static && \
	make && \
	make install && \
	touch $(call depFile,zlib,built)

$(call depFile,zlib,prepared): $(dist)/zlib-$(ZLIB_VERSION).tar.gz
	mkdir -p $(build)
	tar -xzf $(dist)/zlib-$(ZLIB_VERSION).tar.gz -C $(build)
	touch $(call depFile,zlib,prepared)

$(dist)/zlib-$(ZLIB_VERSION).tar.gz:
	mkdir -p $(dist)
	curl --output $(dist)/zlib-$(ZLIB_VERSION).tar.gz --location https://zlib.net/zlib-$(ZLIB_VERSION).tar.gz

openssl: $(call depFile,openssl,built)

$(call depFile,openssl,built): $(call depFile,openssl,prepared)
	cd $(build)/openssl* && \
	./Configure --prefix="$(root)" --cross-compile-prefix="$(host)-" no-shared no-asm linux-elf && \
	make && \
	make install && \
	touch $(call depFile,openssl,built)

$(call depFile,openssl,prepared): $(dist)/openssl-$(OPENSSL_VERSION).tar.gz
	mkdir -p $(build)
	tar -xzf $(dist)/openssl-$(OPENSSL_VERSION).tar.gz -C $(build)
	touch $(call depFile,openssl,prepared)

$(dist)/openssl-$(OPENSSL_VERSION).tar.gz:
	mkdir -p $(dist)
	curl --output $(dist)/openssl-$(OPENSSL_VERSION).tar.gz --location https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz

openssh: $(call depFile,openssh,built)

$(call depFile,openssh,built): $(call depFile,openssh,prepared) $(call depFile,zlib,built) $(call depFile,openssl,built)
	cd $(build)/openssh* && \
	env PATH="$(oldpath)" autoreconf && \
	./configure LDFLAGS="-static $(LDFLAGS)" LIBS="-lpthread" --prefix="$(prefix)" --host="$(host)" --disable-strip --with-privsep-user=root --with-privsep-path=$(prefix)/var/empty && \
	make && \
	make install-nokeys DESTDIR="$$PWD/../../deploy" && \
	touch $(call depFile,openssh,built)

$(call depFile,openssh,prepared): $(dist)/openssh-$(OPENSSH_VERSION).tar.gz
	mkdir -p $(build)
	tar -xzf $(dist)/openssh-$(OPENSSH_VERSION).tar.gz -C $(build)
	touch $(call depFile,openssh,prepared)

$(dist)/openssh-$(OPENSSH_VERSION).tar.gz:
	mkdir -p $(dist)
	curl --output $(dist)/openssh-$(OPENSSH_VERSION).tar.gz --location https://github.com/openssh/openssh-portable/archive/refs/tags/$(OPENSSH_VERSION).tar.gz
