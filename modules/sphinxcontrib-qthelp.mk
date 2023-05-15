################################################################################
# sphinxcontrib-qthelp Python modules
################################################################################

sphinxcontrib-qthelp_dist_url  := https://files.pythonhosted.org/packages/b1/8e/c4846e59f38a5f2b4a0e3b27af38f2fcf904d4bfd82095bf92de0b114ebd/sphinxcontrib-qthelp-1.0.3.tar.gz
sphinxcontrib-qthelp_dist_sum  := 29f77e4b3f1a4868c2a34dbd853415e5d813f482cd23b982aeed42d53acba09b896d77ba930c34cce8af043bb7d64a19acff610430e942038d95a410b6e0b5fa
sphinxcontrib-qthelp_dist_name := $(notdir $(sphinxcontrib-qthelp_dist_url))
sphinxcontrib-qthelp_vers      := $(patsubst sphinxcontrib-qthelp-%.tar.gz,%,$(sphinxcontrib-qthelp_dist_name))
sphinxcontrib-qthelp_brief     := Sphinx_ extension which outputs QtHelp document
sphinxcontrib-qthelp_home      := https://www.sphinx-doc.org/

define sphinxcontrib-qthelp_desc
This module contains a Sphinx_ builder which produces Qt help collection support
files that allow the Qt collection generator to compile them.
endef

define fetch_sphinxcontrib-qthelp_dist
$(call download_csum,$(sphinxcontrib-qthelp_dist_url),\
                     $(sphinxcontrib-qthelp_dist_name),\
                     $(sphinxcontrib-qthelp_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-qthelp,\
                       sphinxcontrib-qthelp_dist_name,\
                       fetch_sphinxcontrib-qthelp_dist)

define xtract_sphinxcontrib-qthelp
$(call rmrf,$(srcdir)/sphinxcontrib-qthelp)
$(call untar,$(srcdir)/sphinxcontrib-qthelp,\
             $(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name),\
             --strip-components=1)
cd $(srcdir)/sphinxcontrib-qthelp && \
	patch -p1 < $(PATCHDIR)/sphinxcontrib-qthelp-1.0.3-000-fix_test_path_read_text_attr.patch
endef
$(call gen_xtract_rules,sphinxcontrib-qthelp,\
                        xtract_sphinxcontrib-qthelp)

$(call gen_dir_rules,sphinxcontrib-qthelp)

# $(1): targets base name / module name
define sphinxcontrib-qthelp_check_cmds
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

check_stage-sphinxcontrib-qthelp = \
	$(call sphinxcontrib-qthelp_check_cmds,\
	       stage-sphinxcontrib-qthelp)

$(call gen_deps,stage-sphinxcontrib-qthelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-qthelp,stage-pytest stage-sphinx)
$(call gen_python_module_rules,stage-sphinxcontrib-qthelp,\
                               sphinxcontrib-qthelp,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-qthelp = \
	$(call sphinxcontrib-qthelp_check_cmds,\
	       final-sphinxcontrib-qthelp)

$(call gen_deps,final-sphinxcontrib-qthelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-qthelp,stage-pytest stage-sphinx)
$(call gen_python_module_rules,final-sphinxcontrib-qthelp,\
                               sphinxcontrib-qthelp,\
                               $(PREFIX),\
                               $(finaldir))
