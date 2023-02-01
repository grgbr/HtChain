outcome_dist_url  := https://files.pythonhosted.org/packages/dd/91/741e1626e89fdc3664169e16300c59eefa4b23540cc6d6c70450f885098f/outcome-1.2.0.tar.gz
outcome_dist_sum  := 6f82bd3de45da303cf1f771ecafa1633750a358436a8bb60e06a1ceb745d2672
outcome_dist_name := $(notdir $(outcome_dist_url))

define fetch_outcome_dist
$(call _download,$(outcome_dist_url),$(FETCHDIR)/$(outcome_dist_name).tmp)
cat $(FETCHDIR)/$(outcome_dist_name).tmp | \
	sha256sum --check --status <(echo "$(outcome_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(outcome_dist_name).tmp,\
          $(FETCHDIR)/$(outcome_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(outcome_dist_name)'
endef

# As fetch_outcome_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(outcome_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,outcome,outcome_dist_name,fetch_outcome_dist)

define xtract_outcome
$(call rmrf,$(srcdir)/outcome)
$(call untar,$(srcdir)/outcome,\
             $(FETCHDIR)/$(outcome_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,outcome,xtract_outcome)

$(call gen_dir_rules,outcome)

# $(1): targets base name / module name
define outcome_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-outcome,stage-attrs)
$(call gen_check_deps,stage-outcome,stage-outcome stage-pytest-asyncio)

check_stage-outcome = $(call outcome_check_cmds,stage-outcome)
$(call gen_python_module_rules,stage-outcome,outcome,\
                                             $(stagedir),\
                                             ,\
                                             check_stage-outcome)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-outcome,stage-attrs)
$(call gen_check_deps,final-outcome,stage-outcome stage-pytest-asyncio)

check_final-outcome = $(call outcome_check_cmds,final-outcome)
$(call gen_python_module_rules,final-outcome,outcome,\
                                             $(PREFIX),\
                                             $(finaldir),\
                                             check_final-outcome)
