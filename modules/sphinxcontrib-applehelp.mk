sphinxcontrib-applehelp_dist_url  := https://files.pythonhosted.org/packages/32/df/45e827f4d7e7fcc84e853bcef1d836effd762d63ccb86f43ede4e98b478c/sphinxcontrib-applehelp-1.0.4.tar.gz
sphinxcontrib-applehelp_dist_sum  := 828f867945bbe39817c210a1abfd1bc4895c8b73fcaade56d45357a348a07d7e
sphinxcontrib-applehelp_dist_name := $(notdir $(sphinxcontrib-applehelp_dist_url))

define fetch_sphinxcontrib-applehelp_dist
$(call _download,$(sphinxcontrib-applehelp_dist_url),\
                 $(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name).tmp)
cat $(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinxcontrib-applehelp_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name).tmp,\
          $(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name)'
endef

# As fetch_sphinxcontrib-applehelp_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,sphinxcontrib-applehelp,\
                       sphinxcontrib-applehelp_dist_name,\
                       fetch_sphinxcontrib-applehelp_dist)

define xtract_sphinxcontrib-applehelp
$(call rmrf,$(srcdir)/sphinxcontrib-applehelp)
$(call untar,$(srcdir)/sphinxcontrib-applehelp,\
             $(FETCHDIR)/$(sphinxcontrib-applehelp_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-applehelp,\
                        xtract_sphinxcontrib-applehelp)

$(call gen_dir_rules,sphinxcontrib-applehelp)

# $(1): targets base name / module name
define sphinxcontrib-applehelp_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinxcontrib-applehelp,stage-setuptools)
$(call gen_check_deps,stage-sphinxcontrib-applehelp,\
                      stage-pytest stage-sphinx)

check_stage-sphinxcontrib-applehelp = \
	$(call sphinxcontrib-applehelp_check_cmds,\
	       stage-sphinxcontrib-applehelp)
$(call gen_python_module_rules,stage-sphinxcontrib-applehelp,\
                               sphinxcontrib-applehelp,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinxcontrib-applehelp)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinxcontrib-applehelp,stage-setuptools)
$(call gen_check_deps,final-sphinxcontrib-applehelp,\
                      stage-pytest stage-sphinx)

check_final-sphinxcontrib-applehelp = \
	$(call sphinxcontrib-applehelp_check_cmds,\
	       final-sphinxcontrib-applehelp)
$(call gen_python_module_rules,final-sphinxcontrib-applehelp,\
                               sphinxcontrib-applehelp,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinxcontrib-applehelp)
