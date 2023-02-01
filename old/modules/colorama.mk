colorama_dist_url  := https://files.pythonhosted.org/packages/d8/53/6f443c9a4a8358a93a6792e2acffb9d9d5cb0a5cfd8802644b7b1c9a02e4/colorama-0.4.6.tar.gz
colorama_dist_sum  := 08695f5cb7ed6e0531a20572697297273c47b8cae5a63ffc6d6ed5c201be6e44
colorama_dist_name := $(notdir $(colorama_dist_url))

define fetch_colorama_dist
$(call _download,$(colorama_dist_url),$(FETCHDIR)/$(colorama_dist_name).tmp)
cat $(FETCHDIR)/$(colorama_dist_name).tmp | \
	sha256sum --check --status <(echo "$(colorama_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(colorama_dist_name).tmp,\
          $(FETCHDIR)/$(colorama_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(colorama_dist_name)'
endef

# As fetch_colorama_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(colorama_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,colorama,colorama_dist_name,fetch_colorama_dist)

define xtract_colorama
$(call rmrf,$(srcdir)/colorama)
$(call untar,$(srcdir)/colorama,\
             $(FETCHDIR)/$(colorama_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,colorama,xtract_colorama)

$(call gen_dir_rules,colorama)

# $(1): targets base name / module name
define colorama_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-colorama,stage-hatchling)
$(call gen_check_deps,stage-colorama,stage-pytest)

check_stage-colorama = $(call colorama_check_cmds,stage-colorama)
$(call gen_python_module_rules,stage-colorama,colorama,\
                                              $(stagedir),\
                                              ,\
                                              check_stage-colorama)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-colorama,stage-hatchling)
$(call gen_check_deps,final-colorama,stage-pytest)

check_final-colorama = $(call colorama_check_cmds,final-colorama)
$(call gen_python_module_rules,final-colorama,colorama,\
                                              $(PREFIX),\
                                              $(finaldir),\
                                              check_final-colorama)
