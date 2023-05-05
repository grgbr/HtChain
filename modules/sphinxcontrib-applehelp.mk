################################################################################
# sphinxcontrib-applehelp Python modules
################################################################################

sphinxcontrib-applehelp_dist_url  := https://files.pythonhosted.org/packages/32/df/45e827f4d7e7fcc84e853bcef1d836effd762d63ccb86f43ede4e98b478c/sphinxcontrib-applehelp-1.0.4.tar.gz
sphinxcontrib-applehelp_dist_sum  := 998249b6ac2061d3fefec508396f407af450794d2c08a255c9384e9b1a6222bb83af5421115790cb689ebf5dce1ca846ae3fcb71b60ea6183d79262969a26218
sphinxcontrib-applehelp_dist_name := $(notdir $(sphinxcontrib-applehelp_dist_url))
sphinxcontrib-applehelp_vers      := $(patsubst sphinxcontrib-applehelp-%.tar.gz,%,$(sphinxcontrib-applehelp_dist_name))
sphinxcontrib-applehelp_brief     := Sphinx_ extension which outputs Apple help books
sphinxcontrib-applehelp_home      := https://www.sphinx-doc.org/

define sphinxcontrib-applehelp_desc
Plugin for the Sphinx_ documentation generation system that can render output in
the Apple help book format.
endef

define fetch_sphinxcontrib-applehelp_dist
$(call download_csum,$(sphinxcontrib-applehelp_dist_url),\
                     $(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name),\
                     $(sphinxcontrib-applehelp_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-applehelp,\
                       sphinxcontrib-applehelp_dist_name,\
                       fetch_sphinxcontrib-applehelp_dist)

define xtract_sphinxcontrib-applehelp
$(call rmrf,$(srcdir)/sphinxcontrib-applehelp)
$(call untar,$(srcdir)/sphinxcontrib-applehelp,\
             $(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-applehelp,\
                        xtract_sphinxcontrib-applehelp)

$(call gen_dir_rules,sphinxcontrib-applehelp)

# $(1): targets base name / module name
define sphinxcontrib-applehelp_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

check_stage-sphinxcontrib-applehelp = \
	$(call sphinxcontrib-applehelp_check_cmds,\
	       stage-sphinxcontrib-applehelp)

$(call gen_deps,stage-sphinxcontrib-applehelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-applehelp,stage-pytest stage-sphinx)
$(call gen_python_module_rules,stage-sphinxcontrib-applehelp,\
                               sphinxcontrib-applehelp,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-applehelp = \
	$(call sphinxcontrib-applehelp_check_cmds,\
	       final-sphinxcontrib-applehelp)

$(call gen_deps,final-sphinxcontrib-applehelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-applehelp,stage-pytest stage-sphinx)
$(call gen_python_module_rules,final-sphinxcontrib-applehelp,\
                               sphinxcontrib-applehelp,\
                               $(PREFIX),\
                               $(finaldir))
