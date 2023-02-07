sphinxcontrib-htmlhelp_dist_url  := https://files.pythonhosted.org/packages/eb/85/93464ac9bd43d248e7c74573d58a791d48c475230bcf000df2b2700b9027/sphinxcontrib-htmlhelp-2.0.0.tar.gz
sphinxcontrib-htmlhelp_dist_sum  := f5f8bb2d0d629f398bf47d0d69c07bc13b65f75a81ad9e2f71a63d4b7a2f6db2
sphinxcontrib-htmlhelp_dist_name := $(notdir $(sphinxcontrib-htmlhelp_dist_url))

define fetch_sphinxcontrib-htmlhelp_dist
$(call _download,$(sphinxcontrib-htmlhelp_dist_url),\
                 $(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name).tmp)
cat $(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinxcontrib-htmlhelp_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name).tmp,\
          $(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name)'
endef

# As fetch_sphinxcontrib-htmlhelp_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinxcontrib-htmlhelp_dist_name): SHELL:=/bin/bash
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
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinxcontrib-htmlhelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-htmlhelp,\
                      stage-pytest stage-sphinx stage-html5lib)

check_stage-sphinxcontrib-htmlhelp = \
	$(call sphinxcontrib-htmlhelp_check_cmds,\
	       stage-sphinxcontrib-htmlhelp)
$(call gen_python_module_rules,stage-sphinxcontrib-htmlhelp,\
                               sphinxcontrib-htmlhelp,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinxcontrib-htmlhelp)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinxcontrib-htmlhelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-htmlhelp,\
                      stage-pytest stage-sphinx stage-html5lib)

check_final-sphinxcontrib-htmlhelp = \
	$(call sphinxcontrib-htmlhelp_check_cmds,\
	       final-sphinxcontrib-htmlhelp)
$(call gen_python_module_rules,final-sphinxcontrib-htmlhelp,\
                               sphinxcontrib-htmlhelp,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinxcontrib-htmlhelp)
