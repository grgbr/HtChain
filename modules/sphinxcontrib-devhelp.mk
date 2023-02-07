sphinxcontrib-devhelp_dist_url  := https://files.pythonhosted.org/packages/98/33/dc28393f16385f722c893cb55539c641c9aaec8d1bc1c15b69ce0ac2dbb3/sphinxcontrib-devhelp-1.0.2.tar.gz
sphinxcontrib-devhelp_dist_sum  := ff7f1afa7b9642e7060379360a67e9c41e8f3121f2ce9164266f61b9f4b338e4
sphinxcontrib-devhelp_dist_name := $(notdir $(sphinxcontrib-devhelp_dist_url))

define fetch_sphinxcontrib-devhelp_dist
$(call _download,$(sphinxcontrib-devhelp_dist_url),\
                 $(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name).tmp)
cat $(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinxcontrib-devhelp_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name).tmp,\
          $(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name)'
endef

# As fetch_sphinxcontrib-devhelp_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,sphinxcontrib-devhelp,\
                       sphinxcontrib-devhelp_dist_name,\
                       fetch_sphinxcontrib-devhelp_dist)

define xtract_sphinxcontrib-devhelp
$(call rmrf,$(srcdir)/sphinxcontrib-devhelp)
$(call untar,$(srcdir)/sphinxcontrib-devhelp,\
             $(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-devhelp,\
                        xtract_sphinxcontrib-devhelp)

$(call gen_dir_rules,sphinxcontrib-devhelp)

# $(1): targets base name / module name
define sphinxcontrib-devhelp_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinxcontrib-devhelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-devhelp,stage-pytest stage-sphinx)

check_stage-sphinxcontrib-devhelp = \
	$(call sphinxcontrib-devhelp_check_cmds,\
	       stage-sphinxcontrib-devhelp)
$(call gen_python_module_rules,stage-sphinxcontrib-devhelp,\
                               sphinxcontrib-devhelp,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinxcontrib-devhelp)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinxcontrib-devhelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-devhelp,stage-pytest stage-sphinx)

check_final-sphinxcontrib-devhelp = \
	$(call sphinxcontrib-devhelp_check_cmds,\
	       final-sphinxcontrib-devhelp)
$(call gen_python_module_rules,final-sphinxcontrib-devhelp,\
                               sphinxcontrib-devhelp,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinxcontrib-devhelp)
