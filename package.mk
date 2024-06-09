include functions.mk

# Adjust the toolchain dir in case the bin subfolder
# sits under an extra subdirectory.
ifneq "$(shell [ -d '$(toolchain_dir)/bin' ] && echo 1)" "1"
  toolchain_dir := $(wildcard $(toolchain_dir)/*)
endif

export host_triplet := $(subst -gcc,,$(firstword $(notdir $(wildcard $(toolchain_dir)/bin/*-gcc))))

ifneq "$(package_name)" ""
  include ./package-single.mk
else
  include ./package-graph.mk
endif
