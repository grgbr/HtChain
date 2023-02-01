elementpath_dist_url  := https://files.pythonhosted.org/packages/11/bc/5afb61dd5d863e5cf77cd952445c50c17e65953405986f19e97e4389692a/elementpath-3.0.2.tar.gz
elementpath_dist_sum  := cca18742dc0f354f79874c41a906e6ce4cc15230b7858d22a861e1ec5946940f
elementpath_dist_name := $(notdir $(elementpath_dist_url))

define fetch_elementpath_dist
$(call _download,$(elementpath_dist_url),\
                 $(FETCHDIR)/$(elementpath_dist_name).tmp)
cat $(FETCHDIR)/$(elementpath_dist_name).tmp | \
	sha256sum --check --status <(echo "$(elementpath_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(elementpath_dist_name).tmp,\
          $(FETCHDIR)/$(elementpath_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(elementpath_dist_name)'
endef

# As fetch_elementpath_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(elementpath_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,elementpath,elementpath_dist_name,fetch_elementpath_dist)

define xtract_elementpath
$(call rmrf,$(srcdir)/elementpath)
$(call untar,$(srcdir)/elementpath,\
             $(FETCHDIR)/$(elementpath_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,elementpath,xtract_elementpath)

$(call gen_dir_rules,elementpath)

# $(1): targets base name / module name
define elementpath_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-elementpath,stage-python)
$(call gen_check_deps,stage-elementpath,stage-pytest)

check_stage-elementpath = $(call elementpath_check_cmds,stage-elementpath)
$(call gen_python_module_rules,stage-elementpath,\
                               elementpath,\
                               $(stagedir),\
                               ,\
                               check_stage-elementpath)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-elementpath,stage-python)
$(call gen_check_deps,final-elementpath,stage-pytest)

check_final-elementpath = $(call elementpath_check_cmds,final-elementpath)
$(call gen_python_module_rules,final-elementpath,\
                               elementpath,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-elementpath)
