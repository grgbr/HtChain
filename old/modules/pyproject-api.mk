pyproject-api_dist_url  := https://files.pythonhosted.org/packages/b8/ec/6f414433d8b924a000ff57e70ea3348182c93f36db77972753f6729b67ef/pyproject_api-1.2.1.tar.gz
pyproject-api_dist_sum  := 093c047d192ceadcab7afd6b501276bf2ce44adf41cb9c313234518cddd20818
pyproject-api_dist_name := $(notdir $(pyproject-api_dist_url))

define fetch_pyproject-api_dist
$(call _download,$(pyproject-api_dist_url),$(FETCHDIR)/$(pyproject-api_dist_name).tmp)
cat $(FETCHDIR)/$(pyproject-api_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pyproject-api_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pyproject-api_dist_name).tmp,\
          $(FETCHDIR)/$(pyproject-api_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pyproject-api_dist_name)'
endef

# As fetch_pyproject-api_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pyproject-api_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pyproject-api,pyproject-api_dist_name,fetch_pyproject-api_dist)

define xtract_pyproject-api
$(call rmrf,$(srcdir)/pyproject-api)
$(call untar,$(srcdir)/pyproject-api,\
             $(FETCHDIR)/$(pyproject-api_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pyproject-api,xtract_pyproject-api)

$(call gen_dir_rules,pyproject-api)

# $(1): targets base name / module name
#
# Disable Python 2 related tests since we do not provide Python 2.
define pyproject-api_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest \
	--deselect tests/test_fronted.py::test_can_build_on_python_2
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pyproject-api,stage-hatch-vcs stage-packaging stage-tomli)
$(call gen_check_deps,stage-pyproject-api,stage-pytest-cov \
                                          stage-pytest-mock \
                                          stage-virtualenv \
                                          stage-wheel)

check_stage-pyproject-api = $(call pyproject-api_check_cmds,stage-pyproject-api)
$(call gen_python_module_rules,stage-pyproject-api,pyproject-api,\
                                                   $(stagedir),\
                                                   ,\
                                                   check_stage-pyproject-api)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pyproject-api,stage-hatch-vcs stage-packaging stage-tomli)
$(call gen_check_deps,final-pyproject-api,stage-pytest-cov \
                                          stage-pytest-mock \
                                          stage-virtualenv \
                                          stage-wheel)


check_final-pyproject-api = $(call pyproject-api_check_cmds,final-pyproject-api)
$(call gen_python_module_rules,final-pyproject-api,pyproject-api,\
                                                   $(PREFIX),\
                                                   $(finaldir),\
                                                   check_final-pyproject-api)
