devpi-process_dist_url  := https://files.pythonhosted.org/packages/fe/db/d68d9b9313302f304c8ebebb2fc48c78f6c33f269179c9ca59d3e4459546/devpi_process-0.3.0.tar.gz
devpi-process_dist_sum  := d2087df90457cc95e5220dddfba96fae7367aa6e8ad25fa819b1088ff5f62502
devpi-process_dist_name := $(notdir $(devpi-process_dist_url))

define fetch_devpi-process_dist
$(call _download,$(devpi-process_dist_url),$(FETCHDIR)/$(devpi-process_dist_name).tmp)
cat $(FETCHDIR)/$(devpi-process_dist_name).tmp | \
	sha256sum --check --status <(echo "$(devpi-process_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(devpi-process_dist_name).tmp,\
          $(FETCHDIR)/$(devpi-process_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(devpi-process_dist_name)'
endef

# As fetch_devpi-process_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(devpi-process_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,devpi-process,devpi-process_dist_name,fetch_devpi-process_dist)

define xtract_devpi-process
$(call rmrf,$(srcdir)/devpi-process)
$(call untar,$(srcdir)/devpi-process,\
             $(FETCHDIR)/$(devpi-process_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,devpi-process,xtract_devpi-process)

$(call gen_dir_rules,devpi-process)

# $(1): targets base name / module name
define devpi-process_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-devpi-process,stage-devpi-client \
                                    stage-devpi-server \
                                    stage-setuptools-scm)
$(call gen_check_deps,stage-devpi-process,stage-pytest-cov \
                                          stage-httpx \
                                          stage-covdefaults)

check_stage-devpi-process = $(call devpi-process_check_cmds,stage-devpi-process)
$(call gen_python_module_rules,stage-devpi-process,devpi-process,\
                                                   $(stagedir),\
                                                   ,\
                                                   check_stage-devpi-process)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-devpi-process,stage-devpi-client \
                                    stage-devpi-server \
                                    stage-setuptools-scm)
$(call gen_check_deps,final-devpi-process,stage-pytest-cov \
                                          stage-httpx \
                                          stage-covdefaults)

check_final-devpi-process = $(call devpi-process_check_cmds,final-devpi-process)
$(call gen_python_module_rules,final-devpi-process,devpi-process,\
                                                   $(PREFIX),\
                                                   $(finaldir),\
                                                   check_final-devpi-process)
