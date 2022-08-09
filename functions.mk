depends = $(subst $(top_dir),./,$(state_dir))/dep.$1.$2

define depfile =
	mkdir -p '$(state_dir)'
	touch '$(top_dir)/$(call depends,$1,$2)'
endef
