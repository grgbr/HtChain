# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

six_dist_url  := https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz
six_dist_sum  := 1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926
six_dist_name := $(notdir $(six_dist_url))

define fetch_six_dist
$(call _download,$(six_dist_url),\
                 $(FETCHDIR)/$(six_dist_name).tmp)
cat $(FETCHDIR)/$(six_dist_name).tmp | \
	sha256sum --check --status <(echo "$(six_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(six_dist_name).tmp,\
          $(FETCHDIR)/$(six_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(six_dist_name)'
endef

# As fetch_six_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(six_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,six,\
                       six_dist_name,\
                       fetch_six_dist)

define xtract_six
$(call rmrf,$(srcdir)/six)
$(call untar,$(srcdir)/six,\
             $(FETCHDIR)/$(six_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,six,xtract_six)

$(call gen_dir_rules,six)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-six,stage-wheel)

$(call gen_python_module_rules,stage-six,six,$(stagedir))
