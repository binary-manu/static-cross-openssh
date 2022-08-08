.PHONY: all clean toolchain packages

export 

top_dir := $(PWD)
toolchain_dir = $(top_dir)/toolchain
staging_dir := $(top_dir)/staging_dir
build_dir := $(top_dir)/build_dir
state_dir := $(top_dir)/state_dir
dl_dir := $(top_dir)/dl
bin_dir := $(top_dir)/bin

all: packages

packages: toolchain
	'$(MAKE)' -f package.mk

toolchain:
	'$(MAKE)' -f toolchain.mk

clean:
	rm -rf '$(bin_dir)' '$(build_dir)' '$(dl_dir)'
	rm -rf '$(staging_dir)' '$(state_dir)' '$(toolchain_dir)'
