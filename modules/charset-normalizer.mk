charset-normalizer_dist_url  := https://files.pythonhosted.org/packages/96/d7/1675d9089a1f4677df5eb29c3f8b064aa1e70c1251a0a8a127803158942d/charset-normalizer-3.0.1.tar.gz
charset-normalizer_dist_sum  := ebea339af930f8ca5d7a699b921106c6e29c617fe9606fa7baa043c1cdae326f
charset-normalizer_dist_name := $(notdir $(charset-normalizer_dist_url))

define fetch_charset-normalizer_dist
$(call _download,$(charset-normalizer_dist_url),\
                 $(FETCHDIR)/$(charset-normalizer_dist_name).tmp)
cat $(FETCHDIR)/$(charset-normalizer_dist_name).tmp | \
	sha256sum --check --status <(echo "$(charset-normalizer_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(charset-normalizer_dist_name).tmp,\
          $(FETCHDIR)/$(charset-normalizer_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(charset-normalizer_dist_name)'
endef

# As fetch_charset-normalizer_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(charset-normalizer_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,charset-normalizer,\
                       charset-normalizer_dist_name,\
                       fetch_charset-normalizer_dist)

define xtract_charset-normalizer
$(call rmrf,$(srcdir)/charset-normalizer)
$(call untar,$(srcdir)/charset-normalizer,\
             $(FETCHDIR)/$(charset-normalizer_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,charset-normalizer,xtract_charset-normalizer)

$(call gen_dir_rules,charset-normalizer)

# $(1): targets base name / module name
define charset-normalizer_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-charset-normalizer,stage-python)
$(call gen_check_deps,stage-charset-normalizer,stage-pytest-cov)

check_stage-charset-normalizer = $(call charset-normalizer_check_cmds,\
                                        stage-charset-normalizer)
$(call gen_python_module_rules,stage-charset-normalizer,\
                               charset-normalizer,\
                               $(stagedir),\
                               ,\
                               check_stage-charset-normalizer)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-charset-normalizer,stage-python)
$(call gen_check_deps,final-charset-normalizer,stage-pytest-cov)

check_final-charset-normalizer = $(call charset-normalizer_check_cmds,\
                                        final-charset-normalizer)
$(call gen_python_module_rules,final-charset-normalizer,\
                               charset-normalizer,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-charset-normalizer)
