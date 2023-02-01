nox_dist_url  := https://files.pythonhosted.org/packages/99/db/e4ecb483ffa194d632ed44bda32cb740e564789fed7e56c2be8e2a0e2aa6/nox-1.5.2.tar.gz
nox_dist_sum  := d8daccb14dc0eae1b6b6eb3ecef79675bd37b4065369f79c35393dd5c55652c7
nox_dist_name := $(notdir $(nox_dist_url))

define fetch_nox_dist
$(call _download,$(nox_dist_url),$(FETCHDIR)/$(nox_dist_name).tmp)
cat $(FETCHDIR)/$(nox_dist_name).tmp | \
	sha256sum --check --status <(echo "$(nox_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(nox_dist_name).tmp,\
          $(FETCHDIR)/$(nox_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(nox_dist_name)'
endef

# As fetch_nox_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(nox_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,nox,nox_dist_name,fetch_nox_dist)

define xtract_nox
$(call rmrf,$(srcdir)/nox)
$(call untar,$(srcdir)/nox,\
             $(FETCHDIR)/$(nox_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,nox,xtract_nox)

$(call gen_dir_rules,nox)

# $(1): targets base name / module name
define nox_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-nox,\
                stage-typing-extensions \
                stage-semantic-version)
$(call gen_check_deps,stage-nox,stage-nox stage-pytest)

check_stage-nox = $(call nox_check_cmds,\
                                     stage-nox)
$(call gen_python_module_rules,stage-nox,\
                               nox,\
                               $(stagedir),\
                               ,\
                               check_stage-nox)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-nox,\
                stage-typing-extensions \
                stage-semantic-version)
$(call gen_check_deps,final-nox,stage-pytest)

check_final-nox = $(call nox_check_cmds,\
                                     final-nox)
$(call gen_python_module_rules,final-nox,\
                               nox,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-nox)
