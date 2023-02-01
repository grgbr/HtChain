appdirs_dist_url  := https://files.pythonhosted.org/packages/d7/d8/05696357e0311f5b5c316d7b95f46c669dd9c15aaeecbb48c7d0aeb88c40/appdirs-1.4.4.tar.gz
appdirs_dist_sum  := 7d5d0167b2b1ba821647616af46a749d1c653740dd0d2415100fe26e27afdf41
appdirs_dist_name := $(notdir $(appdirs_dist_url))

define fetch_appdirs_dist
$(call _download,$(appdirs_dist_url),$(FETCHDIR)/$(appdirs_dist_name).tmp)
cat $(FETCHDIR)/$(appdirs_dist_name).tmp | \
	sha256sum --check --status <(echo "$(appdirs_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(appdirs_dist_name).tmp,\
          $(FETCHDIR)/$(appdirs_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(appdirs_dist_name)'
endef

# As fetch_appdirs_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(appdirs_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,appdirs,appdirs_dist_name,fetch_appdirs_dist)

define xtract_appdirs
$(call rmrf,$(srcdir)/appdirs)
$(call untar,$(srcdir)/appdirs,\
             $(FETCHDIR)/$(appdirs_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,appdirs,xtract_appdirs)

$(call gen_dir_rules,appdirs)

# $(1): targets base name / module name
define appdirs_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-appdirs,stage-python)
$(call gen_check_deps,stage-appdirs,stage-pytest)

check_stage-appdirs = $(call appdirs_check_cmds,stage-appdirs)
$(call gen_python_module_rules,stage-appdirs,appdirs,\
                                             $(stagedir),\
                                             ,\
                                             check_stage-appdirs)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-appdirs,stage-python)
$(call gen_check_deps,final-appdirs,stage-pytest)

check_final-appdirs = $(call appdirs_check_cmds,final-appdirs)
$(call gen_python_module_rules,final-appdirs,appdirs,\
                                             $(PREFIX),\
                                             $(finaldir),\
                                             check_final-appdirs)
