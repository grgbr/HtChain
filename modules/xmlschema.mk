################################################################################
# xmlschema Python modules
################################################################################

xmlschema_dist_url  := https://files.pythonhosted.org/packages/87/82/be78541aeab8d0523d6f967f6fbe892143583978e5f32215f79ac67747e5/xmlschema-2.1.1.tar.gz
xmlschema_dist_sum  := 2c55de21ab4aaba9f499a0b348e60a50939af41b5ce43787c339ce86e4067681acf28b155bfba90346b1e8d976c468ad0ca21f73f76afc55bd700b1866bba945
xmlschema_dist_name := $(notdir $(xmlschema_dist_url))
xmlschema_vers      := $(patsubst xmlschema-%.tar.gz,%,$(xmlschema_dist_name))
xmlschema_brief     := Implementation of XML Schema for Python_
xmlschema_home      := https://github.com/sissaschool/xmlschema

define xmlschema_desc
This library includes the following features:

* full XSD 1.0 and XSD 1.1 support
* building of XML schema objects from XSD files
* validation of XML instances against XSD schemas
* decoding of XML data into Python_ data and to JSON
* encoding of Python_ data and JSON to XML
* data decoding and encoding ruled by converter classes
* an XPath based API for finding schema\'s elements and attributes
* support of XSD validation modes strict/lax/skip
* remote attacks protection by default using an XMLParser that forbids
  entities
endef

define fetch_xmlschema_dist
$(call download_csum,$(xmlschema_dist_url),\
                     $(xmlschema_dist_name),\
                     $(xmlschema_dist_sum))
endef
$(call gen_fetch_rules,xmlschema,xmlschema_dist_name,fetch_xmlschema_dist)

define xtract_xmlschema
$(call rmrf,$(srcdir)/xmlschema)
$(call untar,$(srcdir)/xmlschema,\
             $(FETCHDIR)/$(xmlschema_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,xmlschema,xtract_xmlschema)

$(call gen_dir_rules,xmlschema)

# $(1): targets base name / module name
define xmlschema_check_cmds
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
#
#check_stage-xmlschema = $(call xmlschema_check_cmds,stage-xmlschema)
#
#$(call gen_deps,stage-xmlschema,stage-elementpath)
#$(call gen_check_deps,stage-xmlschema,stage-pytest \
#                                      stage-jinja2 \
#                                      stage-coverage \
#                                      stage-lxml)
#$(call gen_python_module_rules,stage-xmlschema,xmlschema,$(stagedir))

################################################################################
# Final definitions
################################################################################

final-xmlschema_shebang_fixups := bin/xmlschema-xml2json \
                                  bin/xmlschema-json2xml \
                                  bin/xmlschema-validate

define install_final-xmlschema
$(call python_module_install_cmds,final-xmlschema,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-xmlschema_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

check_final-xmlschema = $(call xmlschema_check_cmds,final-xmlschema)

$(call gen_deps,final-xmlschema,stage-elementpath)
$(call gen_check_deps,final-xmlschema,\
                      stage-pytest \
                      stage-jinja2 \
                      stage-coverage \
                      stage-lxml)
$(call gen_python_module_rules,final-xmlschema,xmlschema,$(PREFIX),$(finaldir))
