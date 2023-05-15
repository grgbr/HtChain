################################################################################
# sphinxcontrib-jsmath Python modules
################################################################################

sphinxcontrib-jsmath_dist_url  := https://files.pythonhosted.org/packages/b2/e8/9ed3830aeed71f17c026a07a5097edcf44b692850ef215b161b8ad875729/sphinxcontrib-jsmath-1.0.1.tar.gz
sphinxcontrib-jsmath_dist_sum  := c1e6488f5c0ca4567c27ec7c597c9db321ac32ce354c4ad62fea534b2ae1c0acb183a921f46216bbc3891f14acfaac05ddf324b8fdaf99828df07bc91aa7e5c7
sphinxcontrib-jsmath_dist_name := $(notdir $(sphinxcontrib-jsmath_dist_url))
sphinxcontrib-jsmath_vers      := $(patsubst sphinxcontrib-jsmath-%.tar.gz,%,$(sphinxcontrib-jsmath_dist_name))
sphinxcontrib-jsmath_brief     := Sphinx_ extension to render math in HTML via JavaScript
sphinxcontrib-jsmath_home      := https://www.sphinx-doc.org/

define sphinxcontrib-jsmath_desc
This package provides an extension to the Python_ Sphinx_ documentation system
which renders math as HTML using JavaScript.
endef

define fetch_sphinxcontrib-jsmath_dist
$(call download_csum,$(sphinxcontrib-jsmath_dist_url),\
                     $(sphinxcontrib-jsmath_dist_name),\
                     $(sphinxcontrib-jsmath_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-jsmath,\
                       sphinxcontrib-jsmath_dist_name,\
                       fetch_sphinxcontrib-jsmath_dist)

define xtract_sphinxcontrib-jsmath
$(call rmrf,$(srcdir)/sphinxcontrib-jsmath)
$(call untar,$(srcdir)/sphinxcontrib-jsmath,\
             $(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name),\
             --strip-components=1)
cd $(srcdir)/sphinxcontrib-jsmath && \
	patch -p1 < $(PATCHDIR)/sphinxcontrib-jsmath-1.0.1-000-fix_test_path_read_text_attr.patch
endef
$(call gen_xtract_rules,sphinxcontrib-jsmath,\
                        xtract_sphinxcontrib-jsmath)

$(call gen_dir_rules,sphinxcontrib-jsmath)

# $(1): targets base name / module name
define sphinxcontrib-jsmath_check_cmds
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

check_stage-sphinxcontrib-jsmath = \
	$(call sphinxcontrib-jsmath_check_cmds,\
	       stage-sphinxcontrib-jsmath)

$(call gen_deps,stage-sphinxcontrib-jsmath,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-jsmath,stage-pytest stage-sphinx)
$(call gen_python_module_rules,stage-sphinxcontrib-jsmath,\
                               sphinxcontrib-jsmath,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-jsmath = \
	$(call sphinxcontrib-jsmath_check_cmds,\
	       final-sphinxcontrib-jsmath)

$(call gen_deps,final-sphinxcontrib-jsmath,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-jsmath,stage-pytest stage-sphinx)
$(call gen_python_module_rules,final-sphinxcontrib-jsmath,\
                               sphinxcontrib-jsmath,\
                               $(PREFIX),\
                               $(finaldir))
