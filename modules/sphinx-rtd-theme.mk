################################################################################
# Sphinx Read the Docs theme Python modules
################################################################################

sphinx-rtd-theme_dist_url  := https://files.pythonhosted.org/packages/5e/99/bce1a116ce6cfdcfeffe0a8e30139134dd5dda1269ae8a2995b7c5156d71/sphinx_rtd_theme-1.1.1.tar.gz
sphinx-rtd-theme_dist_sum  := c3e6e3a9d25b9c48a9830e696ca5c8f0c185a0328c76032cbe6dcfb93cda7ad9a724ec4e0e2a99079db28f35aa61ef2f569b87ce98a01c47a9701a6070bc395e
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
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinx-rtd-theme,stage-sphinx)
$(call gen_check_deps,stage-sphinx-rtd-theme,\
                      stage-readthedocs-sphinx-ext stage-pytest)

check_stage-sphinx-rtd-theme = $(call sphinx-rtd-theme_check_cmds,\
                                      stage-sphinx-rtd-theme)
$(call gen_python_module_rules,stage-sphinx-rtd-theme,\
                               sphinx-rtd-theme,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinx-rtd-theme)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinx-rtd-theme,stage-sphinx)
$(call gen_check_deps,final-sphinx-rtd-theme,\
                      stage-readthedocs-sphinx-ext stage-pytest)

check_final-sphinx-rtd-theme = $(call sphinx-rtd-theme_check_cmds,\
                                      final-sphinx-rtd-theme)
$(call gen_python_module_rules,final-sphinx-rtd-theme,\
                               sphinx-rtd-theme,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinx-rtd-theme)
