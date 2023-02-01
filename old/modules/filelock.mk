filelock_dist_url  := https://files.pythonhosted.org/packages/d8/73/292d9ea2370840a163e6dd2d2816a571244e9335e2f6ad957bf0527c492f/filelock-3.8.2.tar.gz
filelock_dist_sum  := 7565f628ea56bfcd8e54e42bdc55da899c85c1abfe1b5bcfd147e9188cebb3b2
filelock_dist_name := $(notdir $(filelock_dist_url))

define fetch_filelock_dist
$(call _download,$(filelock_dist_url),$(FETCHDIR)/$(filelock_dist_name).tmp)
cat $(FETCHDIR)/$(filelock_dist_name).tmp | \
	sha256sum --check --status <(echo "$(filelock_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(filelock_dist_name).tmp,\
          $(FETCHDIR)/$(filelock_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(filelock_dist_name)'
endef

# As fetch_filelock_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(filelock_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,filelock,filelock_dist_name,fetch_filelock_dist)

define xtract_filelock
$(call rmrf,$(srcdir)/filelock)
$(call untar,$(srcdir)/filelock,\
             $(FETCHDIR)/$(filelock_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,filelock,xtract_filelock)

$(call gen_dir_rules,filelock)

# $(1): targets base name / module name
define filelock_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-filelock,stage-python)
$(call gen_check_deps,stage-filelock,\
                      stage-pytest-cov stage-pytest-timeout stage-filelock)

check_stage-filelock = $(call filelock_check_cmds,stage-filelock)
$(call gen_python_module_rules,stage-filelock,\
                               filelock,\
                               $(stagedir),\
                               ,\
                               check_stage-filelock)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-filelock,stage-python)
$(call gen_check_deps,final-filelock,\
                      stage-pytest-cov stage-pytest-timeout stage-filelock)

check_final-filelock = $(call filelock_check_cmds,final-filelock)
$(call gen_python_module_rules,final-filelock,\
                               filelock,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-filelock)
