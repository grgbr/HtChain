################################################################################
# lxml Python modules
################################################################################

lxml_dist_url  := https://files.pythonhosted.org/packages/70/bb/7a2c7b4f8f434aa1ee801704bf08f1e53d7b5feba3d5313ab17003477808/lxml-4.9.1.tar.gz
lxml_dist_sum  := d7ec55c7db2c63a716ca5f4d833706d90fc76c944885e010fcdb96786bcfe796994e438450cf4e8e6e75d702e21fb16971f28f854d7a1f76c34e4ae315414d84
lxml_dist_name := $(notdir $(lxml_dist_url))
lxml_vers      := $(patsubst lxml-%.tar.gz,%,$(lxml_dist_name))
lxml_brief     := Python_ binding for the libxml2_ and libxslt_ libraries
lxml_home      := http://lxml.de/

define lxml_desc
lxml is a new Python_ binding for libxml2_ and libxslt_, completely independent
from existing Python_ bindings. Its aim:

* Pythonic API.
* Documented.
* Use Python_ unicode strings in API.
* Safe (no segfaults).
* No manual memory management!

lxml aims to provide a Pythonic API by following as much as possible the
``ElementTree`` API, trying to avoid inventing too many new APIs, or the user's
having to learn new things -- XML is complicated enough.
endef

define fetch_lxml_dist
$(call download_csum,$(lxml_dist_url),\
                     $(FETCHDIR)/$(lxml_dist_name),\
                     $(lxml_dist_sum))
endef
$(call gen_fetch_rules,lxml,lxml_dist_name,fetch_lxml_dist)

define xtract_lxml
$(call rmrf,$(srcdir)/lxml)
$(call untar,$(srcdir)/lxml,\
             $(FETCHDIR)/$(lxml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,lxml,xtract_lxml)

$(call gen_dir_rules,lxml)

# $(1): targets base name / module name
define lxml_check_cmds
+$(MAKE) -C $(builddir)/$(strip $(1)) \
	inplace3 \
	PATH="$(stagedir)/bin:$(PATH)"
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) test.py -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-lxml,stage-wheel stage-libxml2 stage-libxslt)
$(call gen_check_deps,stage-lxml,stage-pytest)

check_stage-lxml = $(call lxml_check_cmds,stage-lxml)
$(call gen_python_module_rules,stage-lxml,lxml,$(stagedir),,check_stage-lxml)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-lxml,stage-wheel stage-libxml2 stage-libxslt)
$(call gen_check_deps,final-lxml,stage-pytest)

check_final-lxml = $(call lxml_check_cmds,final-lxml)
$(call gen_python_module_rules,final-lxml,\
                               lxml,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-lxml)
