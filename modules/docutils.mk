docutils_dist_url  := https://files.pythonhosted.org/packages/6b/5c/330ea8d383eb2ce973df34d1239b3b21e91cd8c865d21ff82902d952f91f/docutils-0.19.tar.gz
docutils_dist_sum  := 33995a6753c30b7f577febfc2c50411fec6aac7f7ffeb7c4cfe5991072dcf9e6
docutils_dist_name := $(notdir $(docutils_dist_url))

define fetch_docutils_dist
$(call _download,$(docutils_dist_url),$(FETCHDIR)/$(docutils_dist_name).tmp)
cat $(FETCHDIR)/$(docutils_dist_name).tmp | \
	sha256sum --check --status <(echo "$(docutils_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(docutils_dist_name).tmp,\
          $(FETCHDIR)/$(docutils_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(docutils_dist_name)'
endef

# As fetch_docutils_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(docutils_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,docutils,docutils_dist_name,fetch_docutils_dist)

define xtract_docutils
$(call rmrf,$(srcdir)/docutils)
$(call untar,$(srcdir)/docutils,\
             $(FETCHDIR)/$(docutils_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,docutils,xtract_docutils)

$(call gen_dir_rules,docutils)

# $(1): targets base name / module name
define docutils_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) -s $(builddir)/$(strip $(1))/test/alltests.py --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-docutils,stage-python)

check_stage-docutils = $(call docutils_check_cmds,stage-docutils)
$(call gen_python_module_rules,stage-docutils,\
                               docutils,\
                               $(stagedir),\
                               ,\
                               check_stage-docutils)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-docutils,stage-python)

check_final-docutils = $(call docutils_check_cmds,final-docutils)
$(call gen_python_module_rules,final-docutils,\
                               docutils,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-docutils)
