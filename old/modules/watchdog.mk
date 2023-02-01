watchdog_dist_url  := https://files.pythonhosted.org/packages/11/6f/0396d373e039b89c60e23a1a9025edc6dd203121fe0af7d1427e85d5ec98/watchdog-2.2.1.tar.gz
watchdog_dist_sum  := cdcc23c9528601a8a293eb4369cbd14f6b4f34f07ae8769421252e9c22718b6f
watchdog_dist_name := $(notdir $(watchdog_dist_url))

define fetch_watchdog_dist
$(call _download,$(watchdog_dist_url),$(FETCHDIR)/$(watchdog_dist_name).tmp)
cat $(FETCHDIR)/$(watchdog_dist_name).tmp | \
	sha256sum --check --status <(echo "$(watchdog_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(watchdog_dist_name).tmp,\
          $(FETCHDIR)/$(watchdog_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(watchdog_dist_name)'
endef

# As fetch_watchdog_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(watchdog_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,watchdog,watchdog_dist_name,fetch_watchdog_dist)

define xtract_watchdog
$(call rmrf,$(srcdir)/watchdog)
$(call untar,$(srcdir)/watchdog,\
             $(FETCHDIR)/$(watchdog_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,watchdog,xtract_watchdog)

$(call gen_dir_rules,watchdog)

# $(1): targets base name / module name
#
# Skip test_unmount_watched_directory_filesystem tests since requiring sudo
# permissions...
define watchdog_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest \
	--deselect \
	tests/test_inotify_buffer.py::test_unmount_watched_directory_filesystem
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-watchdog,stage-python)
$(call gen_check_deps,stage-watchdog,stage-pytest-cov)

check_stage-watchdog = $(call watchdog_check_cmds,stage-watchdog)
$(call gen_python_module_rules,stage-watchdog,\
                               watchdog,\
                               $(stagedir),\
                               ,\
                               check_stage-watchdog)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-watchdog,stage-python)
$(call gen_check_deps,final-watchdog,stage-pytest-cov)

check_final-watchdog = $(call watchdog_check_cmds,final-watchdog)
$(call gen_python_module_rules,final-watchdog,\
                               watchdog,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-watchdog)
