################################################################################
# elementpath Python modules
################################################################################

elementpath_dist_url  := https://files.pythonhosted.org/packages/11/bc/5afb61dd5d863e5cf77cd952445c50c17e65953405986f19e97e4389692a/elementpath-3.0.2.tar.gz
elementpath_dist_sum  := 43709b8acc9debdc096880e3bdca1bf1b7a82102c1c058533aee94bfa243bb9f379808fb730b208f7c57cbd69b20f8fa154bac8db59a236939273de1eebadad3
elementpath_dist_name := $(notdir $(elementpath_dist_url))
elementpath_vers      := $(patsubst elementpath-%.tar.gz,%,$(elementpath_dist_name))
elementpath_brief     := Providing XPath selectors for Python_\'s XML data structures
elementpath_home      := https://github.com/sissaschool/elementpath

define elementpath_desc
The proposal of this package is to provide XPath 1.0 and 2.0 selectors for
Python_\'s ElementTree XML data structures, both for the standard ElementTree
library and for the lxml.etree library.For lxml.etree.  This package can be
useful for providing XPath 2.0 selectors, because lxml.etree already has it\'s
own implementation of XPath 1.0.
endef

define fetch_elementpath_dist
$(call download_csum,$(elementpath_dist_url),\
                     $(FETCHDIR)/$(elementpath_dist_name),\
                     $(elementpath_dist_sum))
endef
$(call gen_fetch_rules,elementpath,elementpath_dist_name,fetch_elementpath_dist)

define xtract_elementpath
$(call rmrf,$(srcdir)/elementpath)
$(call untar,$(srcdir)/elementpath,\
             $(FETCHDIR)/$(elementpath_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,elementpath,xtract_elementpath)

$(call gen_dir_rules,elementpath)

# $(1): targets base name / module name
define elementpath_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -v
endef

################################################################################
# Staging definitions
################################################################################

check_stage-elementpath = $(call elementpath_check_cmds,stage-elementpath)

$(call gen_deps,stage-elementpath,stage-wheel)
$(call gen_check_deps,stage-elementpath,stage-pytest)
$(call gen_python_module_rules,stage-elementpath,elementpath,$(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-elementpath = $(call elementpath_check_cmds,final-elementpath)

$(call gen_deps,final-elementpath,stage-wheel)
$(call gen_check_deps,final-elementpath,stage-pytest)
$(call gen_python_module_rules,final-elementpath,\
                               elementpath,\
                               $(PREFIX),\
                               $(finaldir))
