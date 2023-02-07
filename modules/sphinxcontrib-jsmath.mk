sphinxcontrib-jsmath_dist_url  := https://files.pythonhosted.org/packages/b2/e8/9ed3830aeed71f17c026a07a5097edcf44b692850ef215b161b8ad875729/sphinxcontrib-jsmath-1.0.1.tar.gz
sphinxcontrib-jsmath_dist_sum  := a9925e4a4587247ed2191a22df5f6970656cb8ca2bd6284309578f2153e0c4b8
sphinxcontrib-jsmath_dist_name := $(notdir $(sphinxcontrib-jsmath_dist_url))

define fetch_sphinxcontrib-jsmath_dist
$(call _download,$(sphinxcontrib-jsmath_dist_url),\
                 $(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name).tmp)
cat $(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinxcontrib-jsmath_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name).tmp,\
          $(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name)'
endef

# As fetch_sphinxcontrib-jsmath_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinxcontrib-jsmath_dist_name): SHELL:=/bin/bash
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
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinxcontrib-jsmath,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-jsmath,stage-pytest stage-sphinx)

check_stage-sphinxcontrib-jsmath = \
	$(call sphinxcontrib-jsmath_check_cmds,\
	       stage-sphinxcontrib-jsmath)
$(call gen_python_module_rules,stage-sphinxcontrib-jsmath,\
                               sphinxcontrib-jsmath,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinxcontrib-jsmath)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinxcontrib-jsmath,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-jsmath,stage-pytest stage-sphinx)

check_final-sphinxcontrib-jsmath = \
	$(call sphinxcontrib-jsmath_check_cmds,\
	       final-sphinxcontrib-jsmath)
$(call gen_python_module_rules,final-sphinxcontrib-jsmath,\
                               sphinxcontrib-jsmath,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinxcontrib-jsmath)
