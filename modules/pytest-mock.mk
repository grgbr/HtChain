# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pytest-mock_dist_url  := https://files.pythonhosted.org/packages/f6/2b/137a7db414aeaf3d753d415a2bc3b90aba8c5f61dff7a7a736d84b2ec60d/pytest-mock-3.10.0.tar.gz
pytest-mock_dist_sum  := fbbdb085ef7c252a326fd8cdcac0aa3b1333d8811f131bdcc701002e1be7ed4f
pytest-mock_dist_name := $(notdir $(pytest-mock_dist_url))

define fetch_pytest-mock_dist
$(call _download,$(pytest-mock_dist_url),$(FETCHDIR)/$(pytest-mock_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-mock_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-mock_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-mock_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-mock_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-mock_dist_name)'
endef

# As fetch_pytest-mock_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-mock_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-mock,pytest-mock_dist_name,fetch_pytest-mock_dist)

define xtract_pytest-mock
$(call rmrf,$(srcdir)/pytest-mock)
$(call untar,$(srcdir)/pytest-mock,\
             $(FETCHDIR)/$(pytest-mock_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-mock,xtract_pytest-mock)

$(call gen_dir_rules,pytest-mock)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-mock,stage-mock stage-pytest)

$(call gen_python_module_rules,stage-pytest-mock,pytest-mock,$(stagedir))
