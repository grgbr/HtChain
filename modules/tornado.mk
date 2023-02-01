# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

tornado_dist_url  := https://files.pythonhosted.org/packages/f3/9e/225a41452f2d9418d89be5e32cf824c84fe1e639d350d6e8d49db5b7f73a/tornado-6.2.tar.gz
tornado_dist_sum  := 9b630419bde84ec666bfd7ea0a4cb2a8a651c2d5cccdbdd1972a0c859dfc3c13
tornado_dist_name := $(notdir $(tornado_dist_url))

define fetch_tornado_dist
$(call _download,$(tornado_dist_url),$(FETCHDIR)/$(tornado_dist_name).tmp)
cat $(FETCHDIR)/$(tornado_dist_name).tmp | \
	sha256sum --check --status <(echo "$(tornado_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(tornado_dist_name).tmp,\
          $(FETCHDIR)/$(tornado_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(tornado_dist_name)'
endef

# As fetch_tornado_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(tornado_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,tornado,\
                       tornado_dist_name,\
                       fetch_tornado_dist)

define xtract_tornado
$(call rmrf,$(srcdir)/tornado)
$(call untar,$(srcdir)/tornado,\
             $(FETCHDIR)/$(tornado_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,tornado,xtract_tornado)

$(call gen_dir_rules,tornado)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-tornado,stage-wheel)

$(call gen_python_module_rules,stage-tornado,tornado,$(stagedir))
