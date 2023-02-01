genshi_dist_url  := https://files.pythonhosted.org/packages/d5/13/bdb68fb9652bb145c341756fbe9563a270fd385ff11410837b59d98ab178/Genshi-0.7.7.tar.gz
genshi_dist_sum  := c100520862cd69085d10ee1a87e91289e7f59f6b3d9bd622bf58b2804e6b9aab
genshi_dist_name := $(notdir $(genshi_dist_url))

define fetch_genshi_dist
$(call _download,$(genshi_dist_url),$(FETCHDIR)/$(genshi_dist_name).tmp)
cat $(FETCHDIR)/$(genshi_dist_name).tmp | \
	sha256sum --check --status <(echo "$(genshi_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(genshi_dist_name).tmp,\
          $(FETCHDIR)/$(genshi_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(genshi_dist_name)'
endef

# As fetch_genshi_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(genshi_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,genshi,genshi_dist_name,fetch_genshi_dist)

define xtract_genshi
$(call rmrf,$(srcdir)/genshi)
$(call untar,$(srcdir)/genshi,\
             $(FETCHDIR)/$(genshi_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,genshi,xtract_genshi)

$(call gen_dir_rules,genshi)

# $(1): targets base name / module name
define genshi_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-genshi,stage-python)
$(call gen_check_deps,stage-genshi,stage-pytest)

check_stage-genshi = $(call genshi_check_cmds,stage-genshi)
$(call gen_python_module_rules,stage-genshi,\
                               genshi,\
                               $(stagedir),\
                               ,\
                               check_stage-genshi)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-genshi,stage-python)
$(call gen_check_deps,final-genshi,stage-pytest)

check_final-genshi = $(call genshi_check_cmds,final-genshi)
$(call gen_python_module_rules,final-genshi,\
                               genshi,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-genshi)
