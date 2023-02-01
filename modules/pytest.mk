# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pytest_dist_url  := https://files.pythonhosted.org/packages/0b/21/055f39bf8861580b43f845f9e8270c7786fe629b2f8562ff09007132e2e7/pytest-7.2.0.tar.gz
pytest_dist_sum  := c4014eb40e10f11f355ad4e3c2fb2c6c6d1919c73f3b5a433de4708202cade59
pytest_dist_name := $(notdir $(pytest_dist_url))

define fetch_pytest_dist
$(call _download,$(pytest_dist_url),$(FETCHDIR)/$(pytest_dist_name).tmp)
cat $(FETCHDIR)/$(pytest_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest_dist_name).tmp,\
          $(FETCHDIR)/$(pytest_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest_dist_name)'
endef

# As fetch_pytest_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest,pytest_dist_name,fetch_pytest_dist)

define xtract_pytest
$(call rmrf,$(srcdir)/pytest)
$(call untar,$(srcdir)/pytest,\
             $(FETCHDIR)/$(pytest_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest,xtract_pytest)

$(call gen_dir_rules,pytest)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest,stage-attrs \
                             stage-exceptiongroup \
                             stage-iniconfig)

$(call gen_python_module_rules,stage-pytest,pytest,$(stagedir))
