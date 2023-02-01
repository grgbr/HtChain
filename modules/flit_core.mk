flit_core_dist_url  := https://files.pythonhosted.org/packages/10/e5/be08751d07b30889af130cec20955c987a74380a10058e6e8856e4010afc/flit_core-3.8.0.tar.gz
flit_core_dist_sum  := b305b30c99526df5e63d6022dd2310a0a941a187bd3884f4c8ef0418df6c39f3
flit_core_dist_name := $(notdir $(flit_core_dist_url))

define fetch_flit_core_dist
$(call _download,$(flit_core_dist_url),$(FETCHDIR)/$(flit_core_dist_name).tmp)
cat $(FETCHDIR)/$(flit_core_dist_name).tmp | \
	sha256sum --check --status <(echo "$(flit_core_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(flit_core_dist_name).tmp,\
          $(FETCHDIR)/$(flit_core_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(flit_core_dist_name)'
endef

# As fetch_flit_core_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(flit_core_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,flit_core,flit_core_dist_name,fetch_flit_core_dist)

define xtract_flit_core
$(call rmrf,$(srcdir)/flit_core)
$(call untar,$(srcdir)/flit_core,\
             $(FETCHDIR)/$(flit_core_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flit_core,xtract_flit_core)

$(call gen_dir_rules,flit_core)

# $(1): targets base name / module name
define flit_core_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flit_core,stage-python)
$(call gen_check_deps,stage-flit_core,stage-pytest stage-testpath)

check_stage-flit_core = $(call flit_core_check_cmds,stage-flit_core)
$(call gen_python_module_rules,stage-flit_core,\
                               flit_core,\
                               $(stagedir),\
                               ,\
                               check_stage-flit_core)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-flit_core,stage-python)
$(call gen_check_deps,final-flit_core,stage-pytest stage-testpath)

check_final-flit_core = $(call flit_core_check_cmds,final-flit_core)
$(call gen_python_module_rules,final-flit_core,\
                               flit_core,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-flit_core)
