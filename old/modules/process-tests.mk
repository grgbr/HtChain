process-tests_dist_url  := https://files.pythonhosted.org/packages/f1/da/2d09f51f8dd4c194b61144ad0410b12151411a12fcc5f5e5c798fb72d7e2/process-tests-2.1.2.tar.gz
process-tests_dist_sum  := a3747ad947bdfc93e5c986bdb17a6d718f3f26e8577a0807a00962f29e26deba
process-tests_dist_name := $(notdir $(process-tests_dist_url))

define fetch_process-tests_dist
$(call _download,$(process-tests_dist_url),$(FETCHDIR)/$(process-tests_dist_name).tmp)
cat $(FETCHDIR)/$(process-tests_dist_name).tmp | \
	sha256sum --check --status <(echo "$(process-tests_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(process-tests_dist_name).tmp,\
          $(FETCHDIR)/$(process-tests_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(process-tests_dist_name)'
endef

# As fetch_process-tests_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(process-tests_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,process-tests,process-tests_dist_name,fetch_process-tests_dist)

define xtract_process-tests
$(call rmrf,$(srcdir)/process-tests)
$(call untar,$(srcdir)/process-tests,\
             $(FETCHDIR)/$(process-tests_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,process-tests,xtract_process-tests)

$(call gen_dir_rules,process-tests)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-process-tests,stage-python)

$(call gen_python_module_rules,stage-process-tests,process-tests,\
                                                   $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-process-tests,stage-python)

$(call gen_python_module_rules,final-process-tests,process-tests,\
                                                   $(PREFIX),\
                                                   $(finaldir))
