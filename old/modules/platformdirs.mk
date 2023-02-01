platformdirs_dist_url  := https://files.pythonhosted.org/packages/cf/4d/198b7e6c6c2b152f4f9f4cdf975d3590e33e63f1920f2d89af7f0390e6db/platformdirs-2.6.2.tar.gz
platformdirs_dist_sum  := e1fea1fe471b9ff8332e229df3cb7de4f53eeea4998d3b6bfff542115e998bd2
platformdirs_dist_name := $(notdir $(platformdirs_dist_url))

define fetch_platformdirs_dist
$(call _download,$(platformdirs_dist_url),$(FETCHDIR)/$(platformdirs_dist_name).tmp)
cat $(FETCHDIR)/$(platformdirs_dist_name).tmp | \
	sha256sum --check --status <(echo "$(platformdirs_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(platformdirs_dist_name).tmp,\
          $(FETCHDIR)/$(platformdirs_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(platformdirs_dist_name)'
endef

# As fetch_platformdirs_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(platformdirs_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,platformdirs,platformdirs_dist_name,fetch_platformdirs_dist)

define xtract_platformdirs
$(call rmrf,$(srcdir)/platformdirs)
$(call untar,$(srcdir)/platformdirs,\
             $(FETCHDIR)/$(platformdirs_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,platformdirs,xtract_platformdirs)

$(call gen_dir_rules,platformdirs)

# $(1): targets base name / module name
define platformdirs_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-platformdirs,stage-hatch-vcs)
$(call gen_check_deps,stage-platformdirs,stage-appdirs \
                                         stage-covdefaults \
                                         stage-pytest-cov \
                                         stage-pytest-mock)

check_stage-platformdirs = $(call platformdirs_check_cmds,stage-platformdirs)
$(call gen_python_module_rules,stage-platformdirs,platformdirs,\
                                                  $(stagedir),\
                                                  ,\
                                                  check_stage-platformdirs)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-platformdirs,stage-hatch-vcs)
$(call gen_check_deps,final-platformdirs,stage-appdirs \
                                         stage-covdefaults \
                                         stage-pytest-cov \
                                         stage-pytest-mock)

check_final-platformdirs = $(call platformdirs_check_cmds,final-platformdirs)
$(call gen_python_module_rules,final-platformdirs,platformdirs,\
                                                  $(PREFIX),\
                                                  $(finaldir),\
                                                  check_final-platformdirs)
