pexpect_dist_url  := https://files.pythonhosted.org/packages/e5/9b/ff402e0e930e70467a7178abb7c128709a30dfb22d8777c043e501bc1b10/pexpect-4.8.0.tar.gz
pexpect_dist_sum  := fc65a43959d153d0114afe13997d439c22823a27cefceb5ff35c2178c6784c0c
pexpect_dist_name := $(notdir $(pexpect_dist_url))

define fetch_pexpect_dist
$(call _download,$(pexpect_dist_url),$(FETCHDIR)/$(pexpect_dist_name).tmp)
cat $(FETCHDIR)/$(pexpect_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pexpect_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pexpect_dist_name).tmp,\
          $(FETCHDIR)/$(pexpect_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pexpect_dist_name)'
endef

# As fetch_pexpect_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pexpect_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pexpect,pexpect_dist_name,fetch_pexpect_dist)

define xtract_pexpect
$(call rmrf,$(srcdir)/pexpect)
$(call untar,$(srcdir)/pexpect,\
             $(FETCHDIR)/$(pexpect_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pexpect,xtract_pexpect)

$(call gen_dir_rules,pexpect)

# $(1): targets base name / module name
#
# Disable bash / readline "bracketed paste" mode causing multiple test failures.
#
# In addition, skip the test_pager_as_cat test case since it relies on
# installed man page database and we don't want to pull in another package
# dependency.
define pexpect_check_cmds
echo 'set enable-bracketed-paste 0' > "$(builddir)/$(strip $(1))/.inputrc"
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    INPUTRC="$(builddir)/$(strip $(1))/.inputrc" \
$(stagedir)/bin/pytest -k 'not test_pager_as_cat'
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pexpect,stage-ptyprocess)
$(call gen_check_deps,stage-pexpect,stage-pytest)

check_stage-pexpect = $(call pexpect_check_cmds,stage-pexpect)
$(call gen_python_module_rules,stage-pexpect,\
                               pexpect,\
                               $(stagedir),\
                               ,\
                               check_stage-pexpect)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pexpect,stage-ptyprocess)
$(call gen_check_deps,final-pexpect,stage-pytest)

check_final-pexpect = $(call pexpect_check_cmds,final-pexpect)
$(call gen_python_module_rules,final-pexpect,\
                               pexpect,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pexpect)
