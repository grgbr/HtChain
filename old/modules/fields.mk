fields_dist_url  := https://files.pythonhosted.org/packages/18/68/b922b5b0b2c1d99171c0ed9ad10296b55ee644eb1fa2fd5e45cafe56ae33/fields-5.0.0.tar.gz
fields_dist_sum  := 31d4aa03d8d44e35df13c431de35136997f047a924a597d84f7bc209e1be5727
fields_dist_name := $(notdir $(fields_dist_url))

define fetch_fields_dist
$(call _download,$(fields_dist_url),$(FETCHDIR)/$(fields_dist_name).tmp)
cat $(FETCHDIR)/$(fields_dist_name).tmp | \
	sha256sum --check --status <(echo "$(fields_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(fields_dist_name).tmp,\
          $(FETCHDIR)/$(fields_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(fields_dist_name)'
endef

# As fetch_fields_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(fields_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,fields,fields_dist_name,fetch_fields_dist)

define xtract_fields
$(call rmrf,$(srcdir)/fields)
$(call untar,$(srcdir)/fields,\
             $(FETCHDIR)/$(fields_dist_name),\
             --strip-components=1)
cd $(srcdir)/fields && \
patch -p1 < $(PATCHDIR)/fields-5.0.0-000-fix_setup_cfg.patch
endef
$(call gen_xtract_rules,fields,xtract_fields)

$(call gen_dir_rules,fields)

# $(1): targets base name / module name
define fields_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest tests/test_fields.py
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-fields,stage-characteristic)
$(call gen_check_deps,stage-fields,stage-pytest stage-fields)

check_stage-fields = $(call fields_check_cmds,stage-fields)
$(call gen_python_module_rules,stage-fields,fields,\
                                            $(stagedir),\
                                            ,\
                                            check_stage-fields)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-fields,stage-characteristic)
$(call gen_check_deps,final-fields,stage-pytest stage-fields)

check_final-fields = $(call fields_check_cmds,final-fields)
$(call gen_python_module_rules,final-fields,fields,\
                                            $(PREFIX),\
                                            $(finaldir),\
                                            check_final-fields)
