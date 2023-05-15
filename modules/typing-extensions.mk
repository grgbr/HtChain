################################################################################
# typing-extensions Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

typing-extensions_dist_url  := https://github.com/python/typing_extensions/archive/refs/tags/4.4.0.tar.gz
typing-extensions_dist_sum  := 1c046e6dab22fb399acf7ab8771d035aa24c88b09cbd023e80a41cd04851c5f8b1d297275012e933658e963e008b073b8d3815f5703042545b57130daa38f143
typing-extensions_vers      := $(subst .tar.gz,,$(notdir $(typing-extensions_dist_url)))
typing-extensions_dist_name := typing-extensions-$(typing-extensions_vers).tar.gz
typing-extensions_brief     := Backported and Experimental Type Hints for Python_
typing-extensions_home      := https://github.com/python/typing_extensions

define typing-extensions_desc
The typing module was added to the standard library in Python_ 3.5 on a
provisional basis and will no longer be provisional in Python_ 3.7. However,
this means users of Python_ 3.5 - 3.6 who are unable to upgrade will not be able
to take advantage of new types added to the typing module, such as typing.Text
or typing.Coroutine.

The typing_extensions module contains both backports of these changes as well as
experimental types that will eventually be added to the typing module, such as
Protocol.

Users of other Python_ versions should continue to install and use the typing
module from `PyPI <https://pypi.org/>`_ instead of using this one unless
specifically writing code that must be compatible with multiple Python_ versions
or requires experimental types.
endef

define fetch_typing-extensions_dist
$(call download_csum,$(typing-extensions_dist_url),\
                     $(typing-extensions_dist_name),\
                     $(typing-extensions_dist_sum))
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
