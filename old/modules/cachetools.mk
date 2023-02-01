cachetools_dist_url  := https://files.pythonhosted.org/packages/c2/6f/278225c5a070a18a76f85db5f1238f66476579fa9b04cda3722331dcc90f/cachetools-5.2.0.tar.gz
cachetools_dist_sum  := 6a94c6402995a99c3970cc7e4884bb60b4a8639938157eeed436098bf9831757
cachetools_dist_name := $(notdir $(cachetools_dist_url))

define fetch_cachetools_dist
$(call _download,$(cachetools_dist_url),$(FETCHDIR)/$(cachetools_dist_name).tmp)
cat $(FETCHDIR)/$(cachetools_dist_name).tmp | \
	sha256sum --check --status <(echo "$(cachetools_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(cachetools_dist_name).tmp,\
          $(FETCHDIR)/$(cachetools_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(cachetools_dist_name)'
endef

# As fetch_cachetools_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(cachetools_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,cachetools,cachetools_dist_name,fetch_cachetools_dist)

define xtract_cachetools
$(call rmrf,$(srcdir)/cachetools)
$(call untar,$(srcdir)/cachetools,\
             $(FETCHDIR)/$(cachetools_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cachetools,xtract_cachetools)

$(call gen_dir_rules,cachetools)

# $(1): targets base name / module name
define cachetools_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cachetools,stage-python)
$(call gen_check_deps,stage-cachetools,stage-pytest stage-cachetools)

check_stage-cachetools = $(call cachetools_check_cmds,stage-cachetools)
$(call gen_python_module_rules,stage-cachetools,cachetools,\
                                                $(stagedir),\
                                                ,\
                                                check_stage-cachetools)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-cachetools,stage-python)
$(call gen_check_deps,final-cachetools,stage-pytest stage-cachetools)

check_final-cachetools = $(call cachetools_check_cmds,final-cachetools)
$(call gen_python_module_rules,final-cachetools,cachetools,\
                                                $(PREFIX),\
                                                $(finaldir),\
                                                check_final-cachetools)
