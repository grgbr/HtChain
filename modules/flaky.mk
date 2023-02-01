# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

flaky_dist_url  := https://files.pythonhosted.org/packages/d5/dd/422c7c5c8c9f4982f3045c73d0571ed4a4faa5754699cc6a6384035fbd80/flaky-3.7.0.tar.gz
flaky_dist_sum  := 3ad100780721a1911f57a165809b7ea265a7863305acb66708220820caf8aa0d
flaky_dist_name := $(notdir $(flaky_dist_url))

define fetch_flaky_dist
$(call _download,$(flaky_dist_url),\
                 $(FETCHDIR)/$(flaky_dist_name).tmp)
cat $(FETCHDIR)/$(flaky_dist_name).tmp | \
	sha256sum --check --status <(echo "$(flaky_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(flaky_dist_name).tmp,\
          $(FETCHDIR)/$(flaky_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(flaky_dist_name)'
endef

# As fetch_flaky_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(flaky_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,flaky,\
                       flaky_dist_name,\
                       fetch_flaky_dist)

define xtract_flaky
$(call rmrf,$(srcdir)/flaky)
$(call untar,$(srcdir)/flaky,\
             $(FETCHDIR)/$(flaky_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flaky,xtract_flaky)

$(call gen_dir_rules,flaky)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flaky,stage-python)

$(call gen_python_module_rules,stage-flaky,flaky,$(stagedir))
