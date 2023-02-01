pytz_dist_url  := https://files.pythonhosted.org/packages/03/3e/dc5c793b62c60d0ca0b7e58f1fdd84d5aaa9f8df23e7589b39cc9ce20a03/pytz-2022.7.1.tar.gz
pytz_dist_sum  := 01a0681c4b9684a28304615eba55d1ab31ae00bf68ec157ec3708a8182dbbcd0
pytz_dist_name := $(notdir $(pytz_dist_url))

define fetch_pytz_dist
$(call _download,$(pytz_dist_url),$(FETCHDIR)/$(pytz_dist_name).tmp)
cat $(FETCHDIR)/$(pytz_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytz_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytz_dist_name).tmp,\
          $(FETCHDIR)/$(pytz_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytz_dist_name)'
endef

# As fetch_pytz_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytz_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytz,pytz_dist_name,fetch_pytz_dist)

define xtract_pytz
$(call rmrf,$(srcdir)/pytz)
$(call untar,$(srcdir)/pytz,\
             $(FETCHDIR)/$(pytz_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytz,xtract_pytz)

$(call gen_dir_rules,pytz)

# $(1): targets base name / module name
define pytz_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytz,stage-wheel)
$(call gen_check_deps,stage-pytz,stage-pytest)

check_stage-pytz = $(call pytz_check_cmds,stage-pytz)
$(call gen_python_module_rules,stage-pytz,\
                               pytz,\
                               $(stagedir),\
                               ,\
                               check_stage-pytz)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytz,stage-wheel)
$(call gen_check_deps,final-pytz,stage-pytest)

check_final-pytz = $(call pytz_check_cmds,final-pytz)
$(call gen_python_module_rules,final-pytz,\
                               pytz,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pytz)
