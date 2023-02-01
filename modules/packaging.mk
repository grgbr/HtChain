packaging_dist_url  := https://files.pythonhosted.org/packages/47/d5/aca8ff6f49aa5565df1c826e7bf5e85a6df852ee063600c1efa5b932968c/packaging-23.0.tar.gz
packaging_dist_sum  := b6ad297f8907de0fa2fe1ccbd26fdaf387f5f47c7275fedf8cce89f99446cf97
packaging_dist_name := $(notdir $(packaging_dist_url))

define fetch_packaging_dist
$(call _download,$(packaging_dist_url),\
                 $(FETCHDIR)/$(packaging_dist_name).tmp)
cat $(FETCHDIR)/$(packaging_dist_name).tmp | \
	sha256sum --check --status <(echo "$(packaging_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(packaging_dist_name).tmp,\
          $(FETCHDIR)/$(packaging_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(packaging_dist_name)'
endef

# As fetch_packaging_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(packaging_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,packaging,\
                       packaging_dist_name,\
                       fetch_packaging_dist)

define xtract_packaging
$(call rmrf,$(srcdir)/packaging)
$(call untar,$(srcdir)/packaging,\
             $(FETCHDIR)/$(packaging_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,packaging,xtract_packaging)

$(call gen_dir_rules,packaging)

# $(1): targets base name / module name
define packaging_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-packaging,stage-flit_core)
$(call gen_check_deps,stage-packaging,stage-pytest stage-pretend)

check_stage-packaging = $(call packaging_check_cmds,stage-packaging)
$(call gen_python_module_rules,stage-packaging,\
                               packaging,\
                               $(stagedir),\
                               ,\
                               check_stage-packaging)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-packaging,stage-flit_core)
$(call gen_check_deps,final-packaging,stage-pytest stage-pretend)

check_final-packaging = $(call packaging_check_cmds,final-packaging)
$(call gen_python_module_rules,final-packaging,packaging,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-packaging)
