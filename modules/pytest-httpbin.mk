# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pytest-httpbin_dist_url  := https://files.pythonhosted.org/packages/c3/18/4638bf234d6f1e3e540cd0b9c117f0df1b75ef2700af03da2d3c3009026c/pytest-httpbin-1.0.2.tar.gz
pytest-httpbin_dist_sum  := 52c9d3f75f8f43f1488b5a0be321eeca3cc5f0fae0c85445ece66bd53c95fe0e
pytest-httpbin_dist_name := $(notdir $(pytest-httpbin_dist_url))

define fetch_pytest-httpbin_dist
$(call _download,$(pytest-httpbin_dist_url),$(FETCHDIR)/$(pytest-httpbin_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-httpbin_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-httpbin_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-httpbin_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-httpbin_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-httpbin_dist_name)'
endef

# As fetch_pytest-httpbin_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-httpbin_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-httpbin,pytest-httpbin_dist_name,fetch_pytest-httpbin_dist)

define xtract_pytest-httpbin
$(call rmrf,$(srcdir)/pytest-httpbin)
$(call untar,$(srcdir)/pytest-httpbin,\
             $(FETCHDIR)/$(pytest-httpbin_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-httpbin,xtract_pytest-httpbin)

$(call gen_dir_rules,pytest-httpbin)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-httpbin,stage-pytest stage-httpbin)

$(call gen_python_module_rules,stage-pytest-httpbin,\
                               pytest-httpbin,\
                               $(stagedir))
