depends = $(notdir $(state_dir))/dep.$1.$2

define depfile =
	mkdir -p '$(state_dir)'
	touch '$(dir $(state_dir))/$(call depends,$1,$2)'
endef
