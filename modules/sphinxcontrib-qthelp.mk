sphinxcontrib-qthelp_dist_url  := https://files.pythonhosted.org/packages/b1/8e/c4846e59f38a5f2b4a0e3b27af38f2fcf904d4bfd82095bf92de0b114ebd/sphinxcontrib-qthelp-1.0.3.tar.gz
sphinxcontrib-qthelp_dist_sum  := 4c33767ee058b70dba89a6fc5c1892c0d57a54be67ddd3e7875a18d14cba5a72
sphinxcontrib-qthelp_dist_name := $(notdir $(sphinxcontrib-qthelp_dist_url))

define fetch_sphinxcontrib-qthelp_dist
$(call _download,$(sphinxcontrib-qthelp_dist_url),\
                 $(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name).tmp)
cat $(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinxcontrib-qthelp_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name).tmp,\
          $(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name)'
endef

# As fetch_sphinxcontrib-qthelp_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinxcontrib-qthelp_dist_name): SHELL:=/bin/bash
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
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinxcontrib-qthelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-qthelp,stage-pytest stage-sphinx)

check_stage-sphinxcontrib-qthelp = \
	$(call sphinxcontrib-qthelp_check_cmds,\
	       stage-sphinxcontrib-qthelp)
$(call gen_python_module_rules,stage-sphinxcontrib-qthelp,\
                               sphinxcontrib-qthelp,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinxcontrib-qthelp)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinxcontrib-qthelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-qthelp,stage-pytest stage-sphinx)

check_final-sphinxcontrib-qthelp = \
	$(call sphinxcontrib-qthelp_check_cmds,\
	       final-sphinxcontrib-qthelp)
$(call gen_python_module_rules,final-sphinxcontrib-qthelp,\
                               sphinxcontrib-qthelp,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinxcontrib-qthelp)
