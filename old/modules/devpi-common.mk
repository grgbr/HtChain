devpi-common_dist_url  := https://files.pythonhosted.org/packages/fa/65/262fd267e9359eeadf542ff17bb1ea5cb2a4f522dc6da88c96a2365962a4/devpi-common-3.7.1.tar.gz
devpi-common_dist_sum  := 6382d25a8eac6c79f6dfda927508f07d93b8732372a061505551af65b46061f4
devpi-common_dist_name := $(notdir $(devpi-common_dist_url))

define fetch_devpi-common_dist
$(call _download,$(devpi-common_dist_url),$(FETCHDIR)/$(devpi-common_dist_name).tmp)
cat $(FETCHDIR)/$(devpi-common_dist_name).tmp | \
	sha256sum --check --status <(echo "$(devpi-common_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(devpi-common_dist_name).tmp,\
          $(FETCHDIR)/$(devpi-common_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(devpi-common_dist_name)'
endef

# As fetch_devpi-common_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(devpi-common_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,devpi-common,devpi-common_dist_name,fetch_devpi-common_dist)

define xtract_devpi-common
$(call rmrf,$(srcdir)/devpi-common)
$(call untar,$(srcdir)/devpi-common,\
             $(FETCHDIR)/$(devpi-common_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,devpi-common,xtract_devpi-common)

$(call gen_dir_rules,devpi-common)

# $(1): targets base name / module name
define devpi-common_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-devpi-common,stage-lazy \
                                   stage-packaging \
                                   stage-py \
                                   stage-requests)
$(call gen_check_deps,stage-devpi-common,stage-pytest)

check_stage-devpi-common = $(call devpi-common_check_cmds,stage-devpi-common)
$(call gen_python_module_rules,stage-devpi-common,devpi-common,\
                                                   $(stagedir),\
                                                   ,\
                                                   check_stage-devpi-common)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-devpi-common,stage-lazy \
                                   stage-packaging \
                                   stage-py \
                                   stage-requests)
$(call gen_check_deps,final-devpi-common,stage-pytest)

check_final-devpi-common = $(call devpi-common_check_cmds,final-devpi-common)
$(call gen_python_module_rules,final-devpi-common,devpi-common,\
                                                   $(PREFIX),\
                                                   $(finaldir),\
                                                   check_final-devpi-common)
