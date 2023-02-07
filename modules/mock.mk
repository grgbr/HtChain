# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

mock_dist_url  := https://files.pythonhosted.org/packages/a9/c8/7f5fc5ee6a666d7e4ee7a3222bcb37ebebaea3697d7bf54517728f56bb28/mock-5.0.1.tar.gz
mock_dist_sum  := e3ea505c03babf7977fd21674a69ad328053d414f05e6433c30d8fa14a534a6b
mock_dist_name := $(notdir $(mock_dist_url))

define fetch_mock_dist
$(call _download,$(mock_dist_url),\
                 $(FETCHDIR)/$(mock_dist_name).tmp)
cat $(FETCHDIR)/$(mock_dist_name).tmp | \
	sha256sum --check --status <(echo "$(mock_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(mock_dist_name).tmp,\
          $(FETCHDIR)/$(mock_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(mock_dist_name)'
endef

# As fetch_mock_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(mock_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,mock,\
                       mock_dist_name,\
                       fetch_mock_dist)

define xtract_mock
$(call rmrf,$(srcdir)/mock)
$(call untar,$(srcdir)/mock,\
             $(FETCHDIR)/$(mock_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,mock,xtract_mock)

$(call gen_dir_rules,mock)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-mock,stage-wheel)

$(call gen_python_module_rules,stage-mock,mock,$(stagedir))
