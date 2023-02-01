# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

execnet_dist_url  := https://files.pythonhosted.org/packages/7a/3c/b5ac9fc61e1e559ced3e40bf5b518a4142536b34eb274aa50dff29cb89f5/execnet-1.9.0.tar.gz
execnet_dist_sum  := 8f694f3ba9cc92cab508b152dcfe322153975c29bda272e2fd7f3f00f36e47c5
execnet_dist_name := $(notdir $(execnet_dist_url))

define fetch_execnet_dist
$(call _download,$(execnet_dist_url),$(FETCHDIR)/$(execnet_dist_name).tmp)
cat $(FETCHDIR)/$(execnet_dist_name).tmp | \
	sha256sum --check --status <(echo "$(execnet_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(execnet_dist_name).tmp,\
          $(FETCHDIR)/$(execnet_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(execnet_dist_name)'
endef

# As fetch_execnet_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(execnet_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,execnet,execnet_dist_name,fetch_execnet_dist)

define xtract_execnet
$(call rmrf,$(srcdir)/execnet)
$(call untar,$(srcdir)/execnet,\
             $(FETCHDIR)/$(execnet_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,execnet,xtract_execnet)

$(call gen_dir_rules,execnet)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-execnet,stage-python)

$(call gen_python_module_rules,stage-execnet,execnet,$(stagedir))
