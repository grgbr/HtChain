nose_dist_url  := https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz
nose_dist_sum  := f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98
nose_dist_name := $(notdir $(nose_dist_url))
nose_vers      := $(patsubst nose-%.tar.gz,%,$(nose_dist_name))

define fetch_nose_dist
$(call _download,$(nose_dist_url),\
                 $(FETCHDIR)/$(nose_dist_name).tmp)
cat $(FETCHDIR)/$(nose_dist_name).tmp | \
	sha256sum --check --status <(echo "$(nose_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(nose_dist_name).tmp,\
          $(FETCHDIR)/$(nose_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(nose_dist_name)'
endef

# As fetch_nose_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(nose_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,nose,\
                       nose_dist_name,\
                       fetch_nose_dist)

define xtract_nose
$(call rmrf,$(srcdir)/nose)
$(call untar,$(srcdir)/nose,\
             $(FETCHDIR)/$(nose_dist_name),\
             --strip-components=1)
cd $(srcdir)/nose || exit 1; \
for p in $(PATCHDIR)/nose-$(nose_vers)-*.patch; do \
	patch -p1 < $$p || exit 1; \
done
cd $(srcdir)/nose/unit_tests/ && \
	patch -p0 < test_issue_100.rst.py3.patch
$(stage_python) -m lib2to3 --write \
                           --nobackups \
                           --no-diffs \
                           $(srcdir)/nose
find $(srcdir)/nose -name '*.rst' | \
	xargs $(stage_python) -m lib2to3 --doctests_only \
	                                 --write \
	                                 --nobackups \
	                                 --no-diffs
endef
$(call gen_xtract_rules,nose,xtract_nose)

$(call gen_dir_rules,nose)

# $(1): targets base name / module name
define nose_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) -m nose -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-nose,stage-coverage stage-mock)

check_stage-nose = $(call nose_check_cmds,stage-nose)
$(call gen_python_module_rules,stage-nose,\
                               nose,\
                               $(stagedir),\
                               ,\
                               check_stage-nose)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-nose,stage-coverage stage-mock)

check_final-nose = $(call nose_check_cmds,final-nose)
$(call gen_python_module_rules,final-nose,nose,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-nose)
