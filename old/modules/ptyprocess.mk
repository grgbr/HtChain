ptyprocess_dist_url  := https://files.pythonhosted.org/packages/20/e5/16ff212c1e452235a90aeb09066144d0c5a6a8c0834397e03f5224495c4e/ptyprocess-0.7.0.tar.gz
ptyprocess_dist_sum  := 5c5d0a3b48ceee0b48485e0c26037c0acd7d29765ca3fbb5cb3831d347423220
ptyprocess_dist_name := $(notdir $(ptyprocess_dist_url))

define fetch_ptyprocess_dist
$(call _download,$(ptyprocess_dist_url),$(FETCHDIR)/$(ptyprocess_dist_name).tmp)
cat $(FETCHDIR)/$(ptyprocess_dist_name).tmp | \
	sha256sum --check --status <(echo "$(ptyprocess_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(ptyprocess_dist_name).tmp,\
          $(FETCHDIR)/$(ptyprocess_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(ptyprocess_dist_name)'
endef

# As fetch_ptyprocess_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(ptyprocess_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,ptyprocess,ptyprocess_dist_name,fetch_ptyprocess_dist)

define xtract_ptyprocess
$(call rmrf,$(srcdir)/ptyprocess)
$(call untar,$(srcdir)/ptyprocess,\
             $(FETCHDIR)/$(ptyprocess_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,ptyprocess,xtract_ptyprocess)

$(call gen_dir_rules,ptyprocess)

# $(1): targets base name / module name
define ptyprocess_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-ptyprocess,stage-python)
$(call gen_check_deps,stage-ptyprocess,stage-pytest)

check_stage-ptyprocess = $(call ptyprocess_check_cmds,stage-ptyprocess)
$(call gen_python_module_rules,stage-ptyprocess,\
                               ptyprocess,\
                               $(stagedir),\
                               ,\
                               check_stage-ptyprocess)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-ptyprocess,stage-python)
$(call gen_check_deps,final-ptyprocess,stage-pytest)

check_final-ptyprocess = $(call ptyprocess_check_cmds,final-ptyprocess)
$(call gen_python_module_rules,final-ptyprocess,\
                               ptyprocess,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-ptyprocess)
