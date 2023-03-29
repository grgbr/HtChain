################################################################################
# sphinxcontrib-jquery Python modules
################################################################################

sphinxcontrib-jquery_dist_url  := https://files.pythonhosted.org/packages/de/f3/aa67467e051df70a6330fe7770894b3e4f09436dea6881ae0b4f3d87cad8/sphinxcontrib-jquery-4.1.tar.gz
sphinxcontrib-jquery_dist_sum  := a686f59b973276e10bf6ece507d2c2f7ff26d46c3a4aef0884f359cb86a9b033bf0d5f1d1e22e0f7e4790dfb99be5ad7ffd8469193180b9ebe348c7ff3ed981c
sphinxcontrib-jquery_dist_name := $(notdir $(sphinxcontrib-jquery_dist_url))
sphinxcontrib-jquery_vers      := $(patsubst sphinxcontrib-jquery-%.tar.gz,%,$(sphinxcontrib-jquery_dist_name))
sphinxcontrib-jquery_brief     := Sphinx_ extension to include jQuery
sphinxcontrib-jquery_home      := https://github.com/sphinx-contrib/jquery/

define sphinxcontrib-jquery_desc
Plugin for the Sphinx_ documentation generation system ensuring that jQuery is
always installed for use in Sphinx_ themes or extensions.
endef

define fetch_sphinxcontrib-jquery_dist
$(call download_csum,$(sphinxcontrib-jquery_dist_url),\
                     $(FETCHDIR)/$(sphinxcontrib-jquery_dist_name),\
                     $(sphinxcontrib-jquery_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-jquery,\
                       sphinxcontrib-jquery_dist_name,\
                       fetch_sphinxcontrib-jquery_dist)

define xtract_sphinxcontrib-jquery
$(call rmrf,$(srcdir)/sphinxcontrib-jquery)
$(call untar,$(srcdir)/sphinxcontrib-jquery,\
             $(FETCHDIR)/$(sphinxcontrib-jquery_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-jquery,\
                        xtract_sphinxcontrib-jquery)

$(call gen_dir_rules,sphinxcontrib-jquery)

# $(1): targets base name / module name
define sphinxcontrib-jquery_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

check_stage-sphinxcontrib-jquery = \
	$(call sphinxcontrib-jquery_check_cmds,\
	       stage-sphinxcontrib-jquery)

$(call gen_deps,stage-sphinxcontrib-jquery,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-jquery,stage-pytest stage-sphinx)
$(call gen_python_module_rules,stage-sphinxcontrib-jquery,\
                               sphinxcontrib-jquery,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-jquery = \
	$(call sphinxcontrib-jquery_check_cmds,\
	       final-sphinxcontrib-jquery)

$(call gen_deps,final-sphinxcontrib-jquery,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-jquery,stage-pytest stage-sphinx)
$(call gen_python_module_rules,final-sphinxcontrib-jquery,\
                               sphinxcontrib-jquery,\
                               $(PREFIX),\
                               $(finaldir))
