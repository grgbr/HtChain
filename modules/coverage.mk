# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

coverage_dist_url  := https://files.pythonhosted.org/packages/84/b3/992a6b222b14c99e6d4aa9f448c670a5f614648597499de6ddc11be839e3/coverage-7.0.5.tar.gz
coverage_dist_sum  := 051afcbd6d2ac39298d62d340f94dbb6a1f31de06dfaf6fcef7b759dd3860c45
coverage_dist_name := $(notdir $(coverage_dist_url))

define fetch_coverage_dist
$(call _download,$(coverage_dist_url),$(FETCHDIR)/$(coverage_dist_name).tmp)
cat $(FETCHDIR)/$(coverage_dist_name).tmp | \
	sha256sum --check --status <(echo "$(coverage_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(coverage_dist_name).tmp,\
          $(FETCHDIR)/$(coverage_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(coverage_dist_name)'
endef

# As fetch_coverage_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(coverage_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,coverage,coverage_dist_name,fetch_coverage_dist)

define xtract_coverage
$(call rmrf,$(srcdir)/coverage)
$(call untar,$(srcdir)/coverage,\
             $(FETCHDIR)/$(coverage_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,coverage,xtract_coverage)

$(call gen_dir_rules,coverage)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-coverage,stage-wheel)

$(call gen_python_module_rules,stage-coverage,\
                               coverage,$(stagedir),\
                               ,\
                               check_stage-coverage)
