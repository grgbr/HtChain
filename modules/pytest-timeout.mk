# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pytest-timeout_dist_url  := https://files.pythonhosted.org/packages/ef/30/37abbd50f86cb802cbcea50d68688438de1a7446d73c8ed8d048173b4b13/pytest-timeout-2.1.0.tar.gz
pytest-timeout_dist_sum  := c07ca07404c612f8abbe22294b23c368e2e5104b521c1790195561f37e1ac3d9
pytest-timeout_dist_name := $(notdir $(pytest-timeout_dist_url))

define fetch_pytest-timeout_dist
$(call _download,$(pytest-timeout_dist_url),$(FETCHDIR)/$(pytest-timeout_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-timeout_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-timeout_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-timeout_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-timeout_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-timeout_dist_name)'
endef

# As fetch_pytest-timeout_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-timeout_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-timeout,pytest-timeout_dist_name,fetch_pytest-timeout_dist)

define xtract_pytest-timeout
$(call rmrf,$(srcdir)/pytest-timeout)
$(call untar,$(srcdir)/pytest-timeout,\
             $(FETCHDIR)/$(pytest-timeout_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-timeout,xtract_pytest-timeout)

$(call gen_dir_rules,pytest-timeout)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-timeout,stage-pytest)

$(call gen_python_module_rules,stage-pytest-timeout,\
                               pytest-timeout,\
                               $(stagedir))
