################################################################################
# Sphinx Read the Docs theme Python modules
################################################################################

sphinx-rtd-theme_dist_url  := https://files.pythonhosted.org/packages/35/b4/40faec6790d4b08a6ef878feddc6ad11c3872b75f52273f1418c39f67cd6/sphinx_rtd_theme-1.2.0.tar.gz
sphinx-rtd-theme_dist_sum  := dd407c648c5512a79e31a106825c6f9ec4696b14d950830ab36faf912ea804b48b3a5d09c6a144e9cead773e4c057cbc809d7582deea1b253ce71b756f7f6b10
sphinx-rtd-theme_dist_name := $(notdir $(sphinx-rtd-theme_dist_url))
sphinx-rtd-theme_vers      := $(patsubst sphinx_rtd_theme-%.tar.gz,%,$(sphinx-rtd-theme_dist_name))
sphinx-rtd-theme_brief     := Sphinx_ theme from readthedocs.org
sphinx-rtd-theme_home      := https://sphinx-rtd-theme.readthedocs.io/

define sphinx-rtd-theme_desc
This mobile-friendly sphinx_ theme was initially created for `Read the Docs
<https://readthedocs.org/>`_, but can be incorporated in any project.

Among other things, it features a left panel with a browseable table of
contents, and a search bar.
endef

define fetch_sphinx-rtd-theme_dist
$(call download_csum,$(sphinx-rtd-theme_dist_url),\
                     $(FETCHDIR)/$(sphinx-rtd-theme_dist_name),\
                     $(sphinx-rtd-theme_dist_sum))
endef
$(call gen_fetch_rules,sphinx-rtd-theme,\
                       sphinx-rtd-theme_dist_name,\
                       fetch_sphinx-rtd-theme_dist)

define xtract_sphinx-rtd-theme
$(call rmrf,$(srcdir)/sphinx-rtd-theme)
$(call untar,$(srcdir)/sphinx-rtd-theme,\
             $(FETCHDIR)/$(sphinx-rtd-theme_dist_name),\
             --strip-components=1)
$(call rmf,$(srcdir)/src/._formula.h)
$(call rmf,$(srcdir)/src/._htmlgen.h)
endef
$(call gen_xtract_rules,sphinx-rtd-theme,xtract_sphinx-rtd-theme)

$(call gen_dir_rules,sphinx-rtd-theme)

# $(1): targets base name / module name
define sphinx-rtd-theme_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-sphinx-rtd-theme = $(call sphinx-rtd-theme_check_cmds,\
                                      stage-sphinx-rtd-theme)

$(call gen_deps,stage-sphinx-rtd-theme,stage-sphinx stage-sphinxcontrib-jquery)
$(call gen_check_deps,stage-sphinx-rtd-theme,\
                      stage-readthedocs-sphinx-ext stage-pytest)
$(call gen_python_module_rules,stage-sphinx-rtd-theme,\
                               sphinx-rtd-theme,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinx-rtd-theme = $(call sphinx-rtd-theme_check_cmds,\
                                      final-sphinx-rtd-theme)

$(call gen_deps,final-sphinx-rtd-theme,stage-sphinx stage-sphinxcontrib-jquery)
$(call gen_check_deps,final-sphinx-rtd-theme,\
                      stage-readthedocs-sphinx-ext stage-pytest)
$(call gen_python_module_rules,final-sphinx-rtd-theme,\
                               sphinx-rtd-theme,\
                               $(PREFIX),\
                               $(finaldir))
