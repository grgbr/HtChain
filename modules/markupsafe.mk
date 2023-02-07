markupsafe_dist_url  := https://files.pythonhosted.org/packages/95/7e/68018b70268fb4a2a605e2be44ab7b4dd7ce7808adae6c5ef32e34f4b55a/MarkupSafe-2.1.2.tar.gz
markupsafe_dist_sum  := abcabc8c2b26036d62d4c746381a6f7cf60aafcc653198ad678306986b09450d
markupsafe_dist_name := $(notdir $(markupsafe_dist_url))

define fetch_markupsafe_dist
$(call _download,$(markupsafe_dist_url),\
                 $(FETCHDIR)/$(markupsafe_dist_name).tmp)
cat $(FETCHDIR)/$(markupsafe_dist_name).tmp | \
	sha256sum --check --status <(echo "$(markupsafe_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(markupsafe_dist_name).tmp,\
          $(FETCHDIR)/$(markupsafe_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(markupsafe_dist_name)'
endef

# As fetch_markupsafe_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(markupsafe_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,markupsafe,\
                       markupsafe_dist_name,\
                       fetch_markupsafe_dist)

define xtract_markupsafe
$(call rmrf,$(srcdir)/markupsafe)
$(call untar,$(srcdir)/markupsafe,\
             $(FETCHDIR)/$(markupsafe_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,markupsafe,xtract_markupsafe)

$(call gen_dir_rules,markupsafe)

# $(1): targets base name / module name
define markupsafe_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-markupsafe,stage-wheel)
$(call gen_check_deps,stage-markupsafe,stage-markupsafe stage-pytest)

check_stage-markupsafe = $(call markupsafe_check_cmds,stage-markupsafe)
$(call gen_python_module_rules,stage-markupsafe,\
                               markupsafe,\
                               $(stagedir),\
                               ,\
                               check_stage-markupsafe)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-markupsafe,stage-wheel)
$(call gen_check_deps,final-markupsafe,stage-markupsafe stage-pytest)

check_final-markupsafe = $(call markupsafe_check_cmds,final-markupsafe)
$(call gen_python_module_rules,final-markupsafe,markupsafe,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-markupsafe)
