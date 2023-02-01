pytest-env_dist_url  := https://files.pythonhosted.org/packages/a3/10/2be3d3ef39212ee94407779260311a6d48e5d484aa4597308c6037878089/pytest_env-0.8.1.tar.gz
pytest-env_dist_sum  := d7b2f5273ec6d1e221757998bc2f50d2474ed7d0b9331b92556011fadc4e9abf
pytest-env_dist_name := $(notdir $(pytest-env_dist_url))

define fetch_pytest-env_dist
$(call _download,$(pytest-env_dist_url),$(FETCHDIR)/$(pytest-env_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-env_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-env_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-env_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-env_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-env_dist_name)'
endef

# As fetch_pytest-env_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-env_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-env,pytest-env_dist_name,fetch_pytest-env_dist)

define xtract_pytest-env
$(call rmrf,$(srcdir)/pytest-env)
$(call untar,$(srcdir)/pytest-env,\
             $(FETCHDIR)/$(pytest-env_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-env,xtract_pytest-env)

$(call gen_dir_rules,pytest-env)

# $(1): targets base name / module name
define pytest-env_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-env,stage-pytest stage-hatch-vcs)
$(call gen_check_deps,stage-pytest-env,stage-pytest-env)

check_stage-pytest-env = $(call pytest-env_check_cmds,stage-pytest-env)
$(call gen_python_module_rules,stage-pytest-env,pytest-env,\
                                                $(stagedir),\
                                                ,\
                                                check_stage-pytest-env)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytest-env,stage-pytest stage-hatch-vcs)
$(call gen_check_deps,final-pytest-env,stage-pytest-env)

check_final-pytest-env = $(call pytest-env_check_cmds,final-pytest-env)
$(call gen_python_module_rules,final-pytest-env,pytest-env,\
                                                $(PREFIX),\
                                                $(finaldir),\
                                                check_final-pytest-env)
