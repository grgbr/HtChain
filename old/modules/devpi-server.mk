devpi-server_dist_url  := https://files.pythonhosted.org/packages/41/fa/aa3e4d4d3725baf9d83d7d8cb1f34db68584867eee8f7e40115bb3c85e85/devpi-server-6.8.0.tar.gz
devpi-server_dist_sum  := 74ba6fdef07bec9dd6ea4869c0df96c5940dd16ab6df8141ddb3206427c975cb
devpi-server_dist_name := $(notdir $(devpi-server_dist_url))

define fetch_devpi-server_dist
$(call _download,$(devpi-server_dist_url),$(FETCHDIR)/$(devpi-server_dist_name).tmp)
cat $(FETCHDIR)/$(devpi-server_dist_name).tmp | \
	sha256sum --check --status <(echo "$(devpi-server_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(devpi-server_dist_name).tmp,\
          $(FETCHDIR)/$(devpi-server_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(devpi-server_dist_name)'
endef

# As fetch_devpi-server_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(devpi-server_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,devpi-server,devpi-server_dist_name,fetch_devpi-server_dist)

define xtract_devpi-server
$(call rmrf,$(srcdir)/devpi-server)
$(call untar,$(srcdir)/devpi-server,\
             $(FETCHDIR)/$(devpi-server_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,devpi-server,xtract_devpi-server)

$(call gen_dir_rules,devpi-server)

# $(1): targets base name / module name
define devpi-server_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-devpi-server,stage-devpi-common)
$(call gen_check_deps,stage-devpi-server,stage-pytest)

check_stage-devpi-server = $(call devpi-server_check_cmds,stage-devpi-server)
$(call gen_python_module_rules,stage-devpi-server,devpi-server,\
                                                   $(stagedir),\
                                                   ,\
                                                   check_stage-devpi-server)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-devpi-server,stage-devpi-common)
$(call gen_check_deps,final-devpi-server,stage-pytest)

check_final-devpi-server = $(call devpi-server_check_cmds,final-devpi-server)
$(call gen_python_module_rules,final-devpi-server,devpi-server,\
                                                   $(PREFIX),\
                                                   $(finaldir),\
                                                   check_final-devpi-server)
