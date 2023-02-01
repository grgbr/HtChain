pytest-forked_dist_url  := https://files.pythonhosted.org/packages/f1/bc/0121a2e386b261b69f4f5aa48e5304c947451dce70d68628cb28d5cd0d28/pytest-forked-1.4.0.tar.gz
pytest-forked_dist_sum  := 8b67587c8f98cbbadfdd804539ed5455b6ed03802203485dd2f53c1422d7440e
pytest-forked_dist_name := $(notdir $(pytest-forked_dist_url))

define fetch_pytest-forked_dist
$(call _download,$(pytest-forked_dist_url),$(FETCHDIR)/$(pytest-forked_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-forked_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-forked_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-forked_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-forked_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-forked_dist_name)'
endef

# As fetch_pytest-forked_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-forked_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-forked,pytest-forked_dist_name,fetch_pytest-forked_dist)

define xtract_pytest-forked
$(call rmrf,$(srcdir)/pytest-forked)
$(call untar,$(srcdir)/pytest-forked,\
             $(FETCHDIR)/$(pytest-forked_dist_name),\
             --strip-components=1)
cd $(srcdir)/pytest-forked && \
patch -p1 < $(PATCHDIR)/pytest-forked-1.4.0-000-fix_test_xfail_fnmatch.patch
endef
$(call gen_xtract_rules,pytest-forked,xtract_pytest-forked)

$(call gen_dir_rules,pytest-forked)

# $(1): targets base name / module name
#
# Disable flaky plugin since not compatible with pytest-forked !
# From the README.rst of flaky (section Compatibility):
#     [...] Works with pytest-xdist but not with the --boxed option. Doctests
#     cannot be marked flaky.
# Note that pytest-forked is the split out of the --boxed option of
# pytest-xdist.
define pytest-forked_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -p no:flaky
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-forked,stage-pytest)
$(call gen_check_deps,stage-pytest-forked,stage-pytest-forked)

check_stage-pytest-forked = $(call pytest-forked_check_cmds,stage-pytest-forked)
$(call gen_python_module_rules,stage-pytest-forked,\
                               pytest-forked,\
                               $(stagedir),\
                               ,\
                               check_stage-pytest-forked)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytest-forked,stage-pytest)
$(call gen_check_deps,final-pytest-forked,stage-pytest-forked)

check_final-pytest-forked = $(call pytest-forked_check_cmds,final-pytest-forked)
$(call gen_python_module_rules,final-pytest-forked,\
                               pytest-forked,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pytest-forked)
