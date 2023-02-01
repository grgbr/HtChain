# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

tomli_dist_url  := https://files.pythonhosted.org/packages/c0/3f/d7af728f075fb08564c5949a9c95e44352e23dee646869fa104a3b2060a3/tomli-2.0.1.tar.gz
tomli_dist_sum  := de526c12914f0c550d15924c62d72abc48d6fe7364aa87328337a31007fe8a4f
tomli_dist_name := $(notdir $(tomli_dist_url))

define fetch_tomli_dist
$(call _download,$(tomli_dist_url),$(FETCHDIR)/$(tomli_dist_name).tmp)
cat $(FETCHDIR)/$(tomli_dist_name).tmp | \
	sha256sum --check --status <(echo "$(tomli_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(tomli_dist_name).tmp,\
          $(FETCHDIR)/$(tomli_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(tomli_dist_name)'
endef

# As fetch_tomli_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(tomli_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,tomli,tomli_dist_name,fetch_tomli_dist)

define xtract_tomli
$(call rmrf,$(srcdir)/tomli)
$(call untar,$(srcdir)/tomli,\
             $(FETCHDIR)/$(tomli_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,tomli,xtract_tomli)

$(call gen_dir_rules,tomli)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-tomli,stage-flit_core)

$(call gen_python_module_rules,stage-tomli,tomli,$(stagedir))
