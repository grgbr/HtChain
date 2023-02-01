# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

typing-extensions_dist_url  := https://github.com/python/typing_extensions/archive/refs/tags/4.4.0.tar.gz
typing-extensions_dist_name := typing_extensions-$(notdir $(typing-extensions_dist_url))

define fetch_typing-extensions_dist
$(call download,$(typing-extensions_dist_url),\
                $(FETCHDIR)/$(typing-extensions_dist_name))
endef
$(call gen_fetch_rules,typing-extensions,\
                       typing-extensions_dist_name,\
                       fetch_typing-extensions_dist)

define xtract_typing-extensions
$(call rmrf,$(srcdir)/typing-extensions)
$(call untar,$(srcdir)/typing-extensions,\
             $(FETCHDIR)/$(typing-extensions_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,typing-extensions,xtract_typing-extensions)

$(call gen_dir_rules,typing-extensions)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-typing-extensions,stage-flit_core)

$(call gen_python_module_rules,stage-typing-extensions,\
                               typing-extensions,\
                               $(stagedir))
