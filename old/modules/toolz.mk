toolz_dist_url  := https://files.pythonhosted.org/packages/cf/05/2008534bbaa716b46a2d795d7b54b999d0f7638fbb9ed0b6e87bfa934f84/toolz-0.12.0.tar.gz
toolz_dist_sum  := 88c570861c440ee3f2f6037c4654613228ff40c93a6c25e0eba70d17282c6194
toolz_dist_name := $(notdir $(toolz_dist_url))

define fetch_toolz_dist
$(call _download,$(toolz_dist_url),\
                 $(FETCHDIR)/$(toolz_dist_name).tmp)
cat $(FETCHDIR)/$(toolz_dist_name).tmp | \
	sha256sum --check --status <(echo "$(toolz_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(toolz_dist_name).tmp,\
          $(FETCHDIR)/$(toolz_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(toolz_dist_name)'
endef

# As fetch_toolz_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(toolz_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,toolz,\
                       toolz_dist_name,\
                       fetch_toolz_dist)

define xtract_toolz
$(call rmrf,$(srcdir)/toolz)
$(call untar,$(srcdir)/toolz,\
             $(FETCHDIR)/$(toolz_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,toolz,xtract_toolz)

$(call gen_dir_rules,toolz)

# $(1): targets base name / module name
define toolz_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest
endef
#$(stage_python) setup.py --no-user-cfg test --verbose

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-toolz,stage-python)
$(call gen_check_deps,stage-toolz,stage-pytest)

check_stage-toolz = $(call toolz_check_cmds,stage-toolz)
$(call gen_python_module_rules,stage-toolz,\
                               toolz,\
                               $(stagedir),\
                               ,\
                               check_stage-toolz)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-toolz,stage-python)
$(call gen_check_deps,final-toolz,stage-pytest)

check_final-toolz = $(call toolz_check_cmds,final-toolz)
$(call gen_python_module_rules,final-toolz,toolz,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-toolz)
