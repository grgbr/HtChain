# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

iniconfig_dist_url  := https://files.pythonhosted.org/packages/d7/4b/cbd8e699e64a6f16ca3a8220661b5f83792b3017d0f79807cb8708d33913/iniconfig-2.0.0.tar.gz
iniconfig_dist_sum  := 2d91e135bf72d31a410b17c16da610a82cb55f6b0477d1a902134b24a455b8b3
iniconfig_dist_name := $(notdir $(iniconfig_dist_url))

define fetch_iniconfig_dist
$(call _download,$(iniconfig_dist_url),$(FETCHDIR)/$(iniconfig_dist_name).tmp)
cat $(FETCHDIR)/$(iniconfig_dist_name).tmp | \
	sha256sum --check --status <(echo "$(iniconfig_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(iniconfig_dist_name).tmp,\
          $(FETCHDIR)/$(iniconfig_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(iniconfig_dist_name)'
endef

# As fetch_iniconfig_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(iniconfig_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,iniconfig,iniconfig_dist_name,fetch_iniconfig_dist)

define xtract_iniconfig
$(call rmrf,$(srcdir)/iniconfig)
$(call untar,$(srcdir)/iniconfig,\
             $(FETCHDIR)/$(iniconfig_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,iniconfig,xtract_iniconfig)

$(call gen_dir_rules,iniconfig)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-iniconfig,stage-hatch-vcs)

$(call gen_python_module_rules,stage-iniconfig,iniconfig,$(stagedir))
