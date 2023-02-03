# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

attrs_dist_url  := https://files.pythonhosted.org/packages/21/31/3f468da74c7de4fcf9b25591e682856389b3400b4b62f201e65f15ea3e07/attrs-22.2.0.tar.gz
attrs_dist_sum  := a7707fb11e21cddd2b25c94c9859dc8306745f0256237493a4ad818ffaf005d1c1e84d55d07fce14eaea18fde4994363227286df2751523e1fe4ef6623562a20
attrs_dist_name := $(notdir $(attrs_dist_url))
attrs_vers      := $(patsubst attrs-%.tar.gz,%,$(attrs_dist_name))
attrs_brief     := Python attributes without boilerplate
attrs_home      := https://www.attrs.org/

define attrs_desc
attrs is Python package with class decorators that ease the chores of
implementing the most common attribute-related object protocols.

You just specify the attributes to work with and attrs gives you:

* a nice human-readable ``__repr__``,
* a complete set of comparison methods,
* an initializer,
* and much more

without writing dull boilerplate code again and again.
endef

define fetch_attrs_dist
$(call download_csum,$(attrs_dist_url),\
                     $(FETCHDIR)/$(attrs_dist_name),\
                     $(attrs_dist_sum))
endef
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
