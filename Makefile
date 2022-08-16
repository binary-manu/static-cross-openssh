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
	'$(MAKE)' -f package.mk clean
	'$(MAKE)' -f toolchain.mk clean

dirclean:
	'$(MAKE)' -f package.mk dirclean
	'$(MAKE)' -f toolchain.mk dirclean

# Delete the toolchain ands its downloads,
# but keep downloaded packages
switch-toolchain:
	'$(MAKE)' -f package.mk dirclean
	'$(MAKE)' -f toolchain.mk clean
