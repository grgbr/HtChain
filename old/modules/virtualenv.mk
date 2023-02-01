virtualenv_dist_url  := https://files.pythonhosted.org/packages/7b/19/65f13cff26c8cc11fdfcb0499cd8f13388dd7b35a79a376755f152b42d86/virtualenv-20.17.1.tar.gz
virtualenv_dist_sum  := f8b927684efc6f1cc206c9db297a570ab9ad0e51c16fa9e45487d36d1905c058
virtualenv_dist_name := $(notdir $(virtualenv_dist_url))

define fetch_virtualenv_dist
$(call _download,$(virtualenv_dist_url),$(FETCHDIR)/$(virtualenv_dist_name).tmp)
cat $(FETCHDIR)/$(virtualenv_dist_name).tmp | \
	sha256sum --check --status <(echo "$(virtualenv_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(virtualenv_dist_name).tmp,\
          $(FETCHDIR)/$(virtualenv_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(virtualenv_dist_name)'
endef

# As fetch_virtualenv_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(virtualenv_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,virtualenv,virtualenv_dist_name,fetch_virtualenv_dist)

define xtract_virtualenv
$(call rmrf,$(srcdir)/virtualenv)
$(call untar,$(srcdir)/virtualenv,\
             $(FETCHDIR)/$(virtualenv_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,virtualenv,xtract_virtualenv)

$(call gen_dir_rules,virtualenv)

# $(1): targets base name / module name
define virtualenv_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest \
	--deselect tests/unit/create/test_creator.py::test_py_pyc_missing
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-virtualenv,stage-setuptools-scm \
                                 stage-distlib \
                                 stage-platformdirs \
                                 stage-filelock)
$(call gen_check_deps,stage-virtualenv,stage-virtualenv \
                                       stage-flaky \
                                       stage-coverage_enable_subprocess \
                                       stage-flaky \
                                       stage-packaging \
                                       stage-pytest-env \
                                       stage-pytest-freezegun \
                                       stage-pytest-mock \
                                       stage-pytest-timeout)

check_stage-virtualenv = $(call virtualenv_check_cmds,stage-virtualenv)
$(call gen_python_module_rules,stage-virtualenv,virtualenv,\
                                                  $(stagedir),\
                                                  ,\
                                                  check_stage-virtualenv)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-virtualenv,stage-setuptools-scm \
                                 stage-distlib \
                                 stage-platformdirs \
                                 stage-filelock)
$(call gen_check_deps,final-virtualenv,stage-virtualenv \
                                       stage-flaky \
                                       stage-coverage_enable_subprocess \
                                       stage-flaky \
                                       stage-packaging \
                                       stage-pytest-env \
                                       stage-pytest-freezegun \
                                       stage-pytest-mock \
                                       stage-pytest-timeout)

check_final-virtualenv = $(call virtualenv_check_cmds,final-virtualenv)
$(call gen_python_module_rules,final-virtualenv,virtualenv,\
                                                  $(PREFIX),\
                                                  $(finaldir),\
                                                  check_final-virtualenv)
