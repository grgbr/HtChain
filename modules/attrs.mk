# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

attrs_dist_url  := https://files.pythonhosted.org/packages/21/31/3f468da74c7de4fcf9b25591e682856389b3400b4b62f201e65f15ea3e07/attrs-22.2.0.tar.gz
attrs_dist_sum  := c9227bfc2f01993c03f68db37d1d15c9690188323c067c641f1a35ca58185f99
attrs_dist_name := $(notdir $(attrs_dist_url))

define fetch_attrs_dist
$(call _download,$(attrs_dist_url),$(FETCHDIR)/$(attrs_dist_name).tmp)
cat $(FETCHDIR)/$(attrs_dist_name).tmp | \
	sha256sum --check --status <(echo "$(attrs_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(attrs_dist_name).tmp,\
          $(FETCHDIR)/$(attrs_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(attrs_dist_name)'
endef

# As fetch_attrs_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(attrs_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,attrs,attrs_dist_name,fetch_attrs_dist)

define xtract_attrs
$(call rmrf,$(srcdir)/attrs)
$(call untar,$(srcdir)/attrs,\
             $(FETCHDIR)/$(attrs_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,attrs,xtract_attrs)

$(call gen_dir_rules,attrs)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-attrs,stage-wheel)

$(call gen_python_module_rules,stage-attrs,attrs,$(stagedir))
