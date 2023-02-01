# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

webencodings_dist_url  := https://files.pythonhosted.org/packages/0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47/webencodings-0.5.1.tar.gz
webencodings_dist_sum  := b36a1c245f2d304965eb4e0a82848379241dc04b865afcc4aab16748587e1923
webencodings_dist_name := $(notdir $(webencodings_dist_url))

define fetch_webencodings_dist
$(call _download,$(webencodings_dist_url),$(FETCHDIR)/$(webencodings_dist_name).tmp)
cat $(FETCHDIR)/$(webencodings_dist_name).tmp | \
	sha256sum --check --status <(echo "$(webencodings_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(webencodings_dist_name).tmp,\
          $(FETCHDIR)/$(webencodings_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(webencodings_dist_name)'
endef

# As fetch_webencodings_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(webencodings_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,webencodings,webencodings_dist_name,fetch_webencodings_dist)

define xtract_webencodings
$(call rmrf,$(srcdir)/webencodings)
$(call untar,$(srcdir)/webencodings,\
             $(FETCHDIR)/$(webencodings_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,webencodings,xtract_webencodings)

$(call gen_dir_rules,webencodings)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-webencodings,stage-python)

$(call gen_python_module_rules,stage-webencodings,webencodings,$(stagedir))
