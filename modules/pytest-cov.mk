pytest-cov_dist_url  := https://files.pythonhosted.org/packages/ea/70/da97fd5f6270c7d2ce07559a19e5bf36a76f0af21500256f005a69d9beba/pytest-cov-4.0.0.tar.gz
pytest-cov_dist_sum  := 996b79efde6433cdbd0088872dbc5fb3ed7fe1578b68cdbba634f14bb8dd0470
pytest-cov_dist_name := $(notdir $(pytest-cov_dist_url))

define fetch_pytest-cov_dist
$(call _download,$(pytest-cov_dist_url),$(FETCHDIR)/$(pytest-cov_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-cov_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-cov_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-cov_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-cov_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-cov_dist_name)'
endef

# As fetch_pytest-cov_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-cov_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-cov,pytest-cov_dist_name,fetch_pytest-cov_dist)

define xtract_pytest-cov
$(call rmrf,$(srcdir)/pytest-cov)
$(call untar,$(srcdir)/pytest-cov,\
             $(FETCHDIR)/$(pytest-cov_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-cov,xtract_pytest-cov)

$(call gen_dir_rules,pytest-cov)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-cov,stage-pytest stage-coverage)

$(call gen_python_module_rules,stage-pytest-cov,pytest-cov,$(stagedir))
