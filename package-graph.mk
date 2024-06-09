override packages := openssh

-include package/*/*.mk

.PHONY: all config
.SHELLFLAGS = -e -c
.ONESHELL:

#############################################
# Dynamically declare dependencies between packages
#############################################
define declaredeps =
  $(eval .PHONY: $1)
  $(eval $1 : $(foreach dep,$($1/DEPENDS),$(dep)); +'$(MAKE)' -f package.mk package_name='$1')
  $(foreach dep,$($1/DEPENDS),$(call declareonce,$(dep)))
endef

define declareonce =
$(if $($1_done),,$(call declaredeps,$1) $(eval $1_done=1))
endef

$(foreach pkg,$(packages),$(call declareonce,$(pkg)))

#############################################
# Targets
#############################################
all: $(packages)

config:
	$(foreach \
	    var,\
	    $(filter %/VERSION,$(filter-out __all__/%,$(.VARIABLES))),\
	    [ -z "$($(var))" ] && { echo "$(var) is empty" >&2; exit 1; };\
	    printf 'export %s := %s\n' '$(var)' '$($(var))' >> '$(config_file)';\
	)
