tox_dist_url  := https://files.pythonhosted.org/packages/ac/ee/3115a77ce5af5ac0c5262bee45bdc2d36c02cad13723d7cec970270ccb59/tox-4.0.19.tar.gz
tox_dist_sum  := 31d95663dc66f8d53fdf0825f1fc931404b1db5380482c5449628f49db767047
tox_dist_name := $(notdir $(tox_dist_url))

define fetch_tox_dist
$(call _download,$(tox_dist_url),$(FETCHDIR)/$(tox_dist_name).tmp)
cat $(FETCHDIR)/$(tox_dist_name).tmp | \
	sha256sum --check --status <(echo "$(tox_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(tox_dist_name).tmp,\
          $(FETCHDIR)/$(tox_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(tox_dist_name)'
endef

# As fetch_tox_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(tox_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,tox,tox_dist_name,fetch_tox_dist)

define xtract_tox
$(call rmrf,$(srcdir)/tox)
$(call untar,$(srcdir)/tox,\
             $(FETCHDIR)/$(tox_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,tox,xtract_tox)

$(call gen_dir_rules,tox)

# $(1): targets base name / module name
define tox_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-tox,stage-packaging \
                          stage-tomli \
                          stage-pluggy \
                          stage-filelock \
                          stage-cachetools \
                          stage-chardet \
                          stage-distlib \
                          stage-platformdirs \
                          stage-pyproject-api \
                          stage-colorama \
                          stage-virtualenv)
$(call gen_check_deps,stage-tox,stage-tox \
                                stage-hatch-vcs \
                                stage-pytest-cov \
                                stage-flaky \
                                stage-mock \
                                stage-pytest-xdist \
                                stage-covdefaults \
                                stage-distlib \
                                stage-devpi-process)

check_stage-tox = $(call tox_check_cmds,stage-tox)
$(call gen_python_module_rules,stage-tox,tox,$(stagedir),,check_stage-tox)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-tox,stage-packaging \
                          stage-tomli \
                          stage-pluggy \
                          stage-filelock \
                          stage-cachetools \
                          stage-chardet \
                          stage-distlib \
                          stage-platformdirs \
                          stage-pyproject-api \
                          stage-colorama \
                          stage-virtualenv)
$(call gen_check_deps,final-tox,stage-tox \
                                stage-hatch-vcs \
                                stage-pytest-cov \
                                stage-flaky \
                                stage-mock \
                                stage-pytest-xdist \
                                stage-covdefaults \
                                stage-distlib \
                                stage-devpi-process)

check_final-tox = $(call tox_check_cmds,final-tox)
$(call gen_python_module_rules,final-tox,tox,\
                                           $(PREFIX),\
                                           $(finaldir),\
                                           check_final-tox)
