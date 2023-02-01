pyyaml_dist_url  := https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz
pyyaml_dist_sum  := 68fb519c14306fec9720a2a5b45bc9f0c8d1b9c72adf45c37baedfcd949c35a2
pyyaml_dist_name := $(notdir $(pyyaml_dist_url))

define fetch_pyyaml_dist
$(call _download,$(pyyaml_dist_url),\
                 $(FETCHDIR)/$(pyyaml_dist_name).tmp)
cat $(FETCHDIR)/$(pyyaml_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pyyaml_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pyyaml_dist_name).tmp,\
          $(FETCHDIR)/$(pyyaml_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pyyaml_dist_name)'
endef

# As fetch_pyyaml_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pyyaml_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pyyaml,\
                       pyyaml_dist_name,\
                       fetch_pyyaml_dist)

define xtract_pyyaml
$(call rmrf,$(srcdir)/pyyaml)
$(call untar,$(srcdir)/pyyaml,\
             $(FETCHDIR)/$(pyyaml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pyyaml,xtract_pyyaml)

$(call gen_dir_rules,pyyaml)

# $(1): targets base name / module name
define pyyaml_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) setup.py --no-user-cfg test
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pyyaml,stage-wheel stage-cython stage-libyaml)

check_stage-pyyaml = $(call pyyaml_check_cmds,stage-pyyaml)
$(call gen_python_module_rules,stage-pyyaml,\
                               pyyaml,\
                               $(stagedir),\
                               ,\
                               check_stage-pyyaml)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pyyaml,stage-wheel stage-cython stage-libyaml)

check_final-pyyaml = $(call pyyaml_check_cmds,final-pyyaml)
$(call gen_python_module_rules,final-pyyaml,\
                               pyyaml,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pyyaml)
