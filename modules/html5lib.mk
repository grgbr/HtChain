# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

html5lib_dist_url  := https://files.pythonhosted.org/packages/ac/b6/b55c3f49042f1df3dcd422b7f224f939892ee94f22abcf503a9b7339eaf2/html5lib-1.1.tar.gz
html5lib_dist_sum  := b2e5b40261e20f354d198eae92afc10d750afb487ed5e50f9c4eaf07c184146f
html5lib_dist_name := $(notdir $(html5lib_dist_url))

define fetch_html5lib_dist
$(call _download,$(html5lib_dist_url),$(FETCHDIR)/$(html5lib_dist_name).tmp)
cat $(FETCHDIR)/$(html5lib_dist_name).tmp | \
	sha256sum --check --status <(echo "$(html5lib_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(html5lib_dist_name).tmp,\
          $(FETCHDIR)/$(html5lib_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(html5lib_dist_name)'
endef

# As fetch_html5lib_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(html5lib_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,html5lib,html5lib_dist_name,fetch_html5lib_dist)

define xtract_html5lib
$(call rmrf,$(srcdir)/html5lib)
$(call untar,$(srcdir)/html5lib,\
             $(FETCHDIR)/$(html5lib_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,html5lib,xtract_html5lib)

$(call gen_dir_rules,html5lib)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-html5lib,stage-six stage-webencodings)

$(call gen_python_module_rules,stage-html5lib,html5lib,$(stagedir))
