################################################################################
# sphinxcontrib-devhelp Python modules
################################################################################

sphinxcontrib-devhelp_dist_url  := https://files.pythonhosted.org/packages/98/33/dc28393f16385f722c893cb55539c641c9aaec8d1bc1c15b69ce0ac2dbb3/sphinxcontrib-devhelp-1.0.2.tar.gz
sphinxcontrib-devhelp_dist_sum  := 83b46eaf26df3932ea2136cfda1c0fca4fc08ce8bca564845b3efe5bb00d6c8c93991f4edd4913d4ec796e2d85bd2c7265adf28e98f42e8094daeb5ac11a0eb1
sphinxcontrib-devhelp_dist_name := $(notdir $(sphinxcontrib-devhelp_dist_url))
sphinxcontrib-devhelp_vers      := $(patsubst sphinxcontrib-devhelp-%.tar.gz,%,$(sphinxcontrib-devhelp_dist_name))
sphinxcontrib-devhelp_brief     := Sphinx_ extension which outputs Devhelp document
sphinxcontrib-devhelp_home      := http://sphinx-doc.org/

define sphinxcontrib-devhelp_desc
This module contains a Sphinx_ builder which produces
`GNOME <https://www.gnome.org/>`_ Devhelp support file that allows the
`GNOME <https://www.gnome.org/>`_ Devhelp reader to view them.
endef

define fetch_sphinxcontrib-devhelp_dist
$(call download_csum,$(sphinxcontrib-devhelp_dist_url),\
                     $(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name),\
                     $(sphinxcontrib-devhelp_dist_sum))
endef
$(call gen_fetch_rules,sphinxcontrib-devhelp,\
                       sphinxcontrib-devhelp_dist_name,\
                       fetch_sphinxcontrib-devhelp_dist)

define xtract_sphinxcontrib-devhelp
$(call rmrf,$(srcdir)/sphinxcontrib-devhelp)
$(call untar,$(srcdir)/sphinxcontrib-devhelp,\
             $(FETCHDIR)/$(sphinxcontrib-devhelp_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-devhelp,\
                        xtract_sphinxcontrib-devhelp)

$(call gen_dir_rules,sphinxcontrib-devhelp)

# $(1): targets base name / module name
define sphinxcontrib-devhelp_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

check_stage-sphinxcontrib-devhelp = \
	$(call sphinxcontrib-devhelp_check_cmds,\
	       stage-sphinxcontrib-devhelp)

$(call gen_deps,stage-sphinxcontrib-devhelp,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-devhelp,stage-pytest stage-sphinx)
$(call gen_python_module_rules,stage-sphinxcontrib-devhelp,\
                               sphinxcontrib-devhelp,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-sphinxcontrib-devhelp = \
	$(call sphinxcontrib-devhelp_check_cmds,\
	       final-sphinxcontrib-devhelp)

$(call gen_deps,final-sphinxcontrib-devhelp,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-devhelp,stage-pytest stage-sphinx)
$(call gen_python_module_rules,final-sphinxcontrib-devhelp,\
                               sphinxcontrib-devhelp,\
                               $(PREFIX),\
                               $(finaldir))
