characteristic_dist_url  := https://files.pythonhosted.org/packages/dc/66/54b7a4758ea44fbc93895c7745060005272560fb2c356f2a6f7448ef9a80/characteristic-14.3.0.tar.gz
characteristic_dist_sum  := ded68d4e424115ed44e5c83c2a901a0b6157a959079d7591d92106ffd3ada380
characteristic_dist_name := $(notdir $(characteristic_dist_url))

define fetch_characteristic_dist
$(call _download,$(characteristic_dist_url),$(FETCHDIR)/$(characteristic_dist_name).tmp)
cat $(FETCHDIR)/$(characteristic_dist_name).tmp | \
	sha256sum --check --status <(echo "$(characteristic_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(characteristic_dist_name).tmp,\
          $(FETCHDIR)/$(characteristic_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(characteristic_dist_name)'
endef

# As fetch_characteristic_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(characteristic_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,characteristic,characteristic_dist_name,fetch_characteristic_dist)

define xtract_characteristic
$(call rmrf,$(srcdir)/characteristic)
$(call untar,$(srcdir)/characteristic,\
             $(FETCHDIR)/$(characteristic_dist_name),\
             --strip-components=1)
cd $(srcdir)/characteristic && \
patch -p1 < $(PATCHDIR)/characteristic-14.3.0-000-fix_setup_cfg.patch
endef
$(call gen_xtract_rules,characteristic,xtract_characteristic)

$(call gen_dir_rules,characteristic)

# $(1): targets base name / module name
define characteristic_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-characteristic,stage-python)
$(call gen_check_deps,stage-characteristic,stage-pytest)

check_stage-characteristic = $(call characteristic_check_cmds,\
                                    stage-characteristic)
$(call gen_python_module_rules,stage-characteristic,\
                               characteristic,\
                               $(stagedir),\
                               ,\
                               check_stage-characteristic)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-characteristic,stage-python)
$(call gen_check_deps,final-characteristic,stage-pytest)

check_final-characteristic = $(call characteristic_check_cmds,\
                                    final-characteristic)
$(call gen_python_module_rules,final-characteristic,\
                               characteristic,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-characteristic)
