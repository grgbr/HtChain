################################################################################
# sphinxcontrib-serializinghtml Python modules
################################################################################

sphinxcontrib-serializinghtml_dist_url  := https://files.pythonhosted.org/packages/b5/72/835d6fadb9e5d02304cf39b18f93d227cd93abd3c41ebf58e6853eeb1455/sphinxcontrib-serializinghtml-1.1.5.tar.gz
sphinxcontrib-serializinghtml_dist_sum  := c5aabe4d29fd0455c269f8054089fdd61e1de5c35aa407740fc3baae4cfb3235d9fd5515c0489b0becd12abc8f18d0f42aa169ed315c00f30ba87e64ce851667
sphinxcontrib-serializinghtml_dist_name := $(notdir $(sphinxcontrib-serializinghtml_dist_url))
sphinxcontrib-serializinghtml_vers      := $(patsubst sphinxcontrib-serializinghtml-%.tar.gz,%,$(sphinxcontrib-serializinghtml_dist_name))
sphinxcontrib-serializinghtml_brief     := Sphinx_ extension which outputs serialized HTML files (json and pickle)
sphinxcontrib-serializinghtml_home      := https://www.sphinx-doc.org/

define sphinxcontrib-serializinghtml_desc
This module contains two Sphinx_ builders, json and pickle, which produce
serialized HTML code. It also provides an abstract class which one may use for
serialization in custom formats.

See the "Serialization builder details" section in Sphinx documentation for
details on how the output looks like and how to configure it.
endef

define fetch_sphinxcontrib-serializinghtml_dist
$(call download_csum,$(sphinxcontrib-serializinghtml_dist_url),\
                     $(sphinxcontrib-serializinghtml_dist_name),\
                     $(sphinxcontrib-serializinghtml_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-serializinghtml,\
                       sphinxcontrib-serializinghtml_dist_name,\
                       fetch_sphinxcontrib-serializinghtml_dist)

define xtract_sphinxcontrib-serializinghtml
$(call rmrf,$(srcdir)/sphinxcontrib-serializinghtml)
$(call untar,$(srcdir)/sphinxcontrib-serializinghtml,\
             $(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-serializinghtml,\
                        xtract_sphinxcontrib-serializinghtml)

$(call gen_dir_rules,sphinxcontrib-serializinghtml)

# $(1): targets base name / module name
define sphinxcontrib-serializinghtml_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

check_stage-sphinxcontrib-serializinghtml = \
	$(call sphinxcontrib-serializinghtml_check_cmds,\
	       stage-sphinxcontrib-serializinghtml)

$(call gen_deps,stage-sphinxcontrib-serializinghtml,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-serializinghtml,\
                      stage-pytest stage-sphinx)
$(call gen_python_module_rules,stage-sphinxcontrib-serializinghtml,\
                               sphinxcontrib-serializinghtml,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-serializinghtml = \
	$(call sphinxcontrib-serializinghtml_check_cmds,\
	       final-sphinxcontrib-serializinghtml)

$(call gen_deps,final-sphinxcontrib-serializinghtml,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-serializinghtml,\
                      stage-pytest stage-sphinx)
$(call gen_python_module_rules,final-sphinxcontrib-serializinghtml,\
                               sphinxcontrib-serializinghtml,\
                               $(PREFIX),\
                               $(finaldir))
