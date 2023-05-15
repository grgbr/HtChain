################################################################################
# sphinxcontrib-htmlhelp Python modules
################################################################################

sphinxcontrib-htmlhelp_dist_url  := https://files.pythonhosted.org/packages/eb/85/93464ac9bd43d248e7c74573d58a791d48c475230bcf000df2b2700b9027/sphinxcontrib-htmlhelp-2.0.0.tar.gz
sphinxcontrib-htmlhelp_dist_sum  := 6ed673966615f3e818e00de4b7e59c27f0a0d7b494294f804540777c580480870c36002c08d8ad626b7b41a676fe40edc0b0b5ffc6ad8080f38f59c24e157636
sphinxcontrib-htmlhelp_dist_name := $(notdir $(sphinxcontrib-htmlhelp_dist_url))
sphinxcontrib-htmlhelp_vers      := $(patsubst sphinxcontrib-htmlhelp-%.tar.gz,%,$(sphinxcontrib-htmlhelp_dist_name))
sphinxcontrib-htmlhelp_brief     := Sphinx_ extension which renders HTML help files
sphinxcontrib-htmlhelp_home      := https://www.sphinx-doc.org/

define sphinxcontrib-htmlhelp_desc
This package provides an extension to the Python_ Sphinx_ documentation system
which outputs HTML help files.
endef

define fetch_sphinxcontrib-htmlhelp_dist
$(call download_csum,$(sphinxcontrib-htmlhelp_dist_url),\
                     $(sphinxcontrib-htmlhelp_dist_name),\
                     $(sphinxcontrib-htmlhelp_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-htmlhelp,\
                       sphinxcontrib-htmlhelp_dist_name,\
                       fetch_sphinxcontrib-htmlhelp_dist)

define xtract_sphinxcontrib-htmlhelp
$(call rmrf,$(srcdir)/sphinxcontrib-htmlhelp)
$(call untar,$(srcdir)/sphinxcontrib-htmlhelp,\
             $(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name),\
             --strip-components=1)
cd $(srcdir)/sphinxcontrib-htmlhelp && \
	patch -p1 < $(PATCHDIR)/sphinxcontrib-htmlhelp-2.0.0-000-fix_test_path_read_text_attr.patch
endef
$(call gen_xtract_rules,sphinxcontrib-htmlhelp,\
                        xtract_sphinxcontrib-htmlhelp)

$(call gen_dir_rules,sphinxcontrib-htmlhelp)

# $(1): targets base name / module name
define sphinxcontrib-htmlhelp_check_cmds
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

check_stage-sphinxcontrib-htmlhelp = \
	$(call sphinxcontrib-htmlhelp_check_cmds,\
	       stage-sphinxcontrib-htmlhelp)

$(call gen_deps,stage-sphinxcontrib-htmlhelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-htmlhelp,\
                      stage-pytest stage-sphinx stage-html5lib)
$(call gen_python_module_rules,stage-sphinxcontrib-htmlhelp,\
                               sphinxcontrib-htmlhelp,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-htmlhelp = \
	$(call sphinxcontrib-htmlhelp_check_cmds,\
	       final-sphinxcontrib-htmlhelp)

$(call gen_deps,final-sphinxcontrib-htmlhelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-htmlhelp,\
                      stage-pytest stage-sphinx stage-html5lib)
$(call gen_python_module_rules,final-sphinxcontrib-htmlhelp,\
                               sphinxcontrib-htmlhelp,\
                               $(PREFIX),\
                               $(finaldir))
