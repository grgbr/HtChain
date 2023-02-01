sphinx-rtd-theme_dist_url  := https://files.pythonhosted.org/packages/5e/99/bce1a116ce6cfdcfeffe0a8e30139134dd5dda1269ae8a2995b7c5156d71/sphinx_rtd_theme-1.1.1.tar.gz
sphinx-rtd-theme_dist_sum  := 6146c845f1e1947b3c3dd4432c28998a1693ccc742b4f9ad7c63129f0757c103
sphinx-rtd-theme_dist_name := $(notdir $(sphinx-rtd-theme_dist_url))

define fetch_sphinx-rtd-theme_dist
$(call _download,$(sphinx-rtd-theme_dist_url),\
                 $(FETCHDIR)/$(sphinx-rtd-theme_dist_name).tmp)
cat $(FETCHDIR)/$(sphinx-rtd-theme_dist_name).tmp | \
	sha256sum --check --status <(echo "$(sphinx-rtd-theme_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinx-rtd-theme_dist_name).tmp,\
          $(FETCHDIR)/$(sphinx-rtd-theme_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinx-rtd-theme_dist_name)'
endef

# As fetch_sphinx-rtd-theme_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinx-rtd-theme_dist_name): SHELL:=/bin/bash
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
