################################################################################
# editables modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

editables_dist_url  := https://files.pythonhosted.org/packages/01/b0/a2a87db4b6cb8e7d57004b6836faa634e0747e3e39ded126cdbe5a33ba36/editables-0.3.tar.gz
editables_dist_sum  := 4bdd1f43100cb1f9d46135f422ebe512d6fd61b47ab30c7a2ddb34515f3032cf1a6a28900c866b1b4b7b1bb267aadbe93efe2f41163a82666251b9e9f5cb1210
editables_dist_name := $(notdir $(editables_dist_url))
editables_vers      := $(patsubst editables-%.tar.gz,%,$(editables_dist_name))
editables_brief     := A Python_ library for creating editable :ref:`Wheels <wheel>`
editables_home      := https://github.com/pfmoore/editables

define editables_desc
This library supports the building of `wheels<wheel>`_ which, when installed,
will expose packages in a local directory on ``sys.path`` in "editable mode". In
other words, changes to the package source will be reflected in the package
visible to Python_, without needing a reinstall.
endef

define fetch_editables_dist
$(call download_csum,$(editables_dist_url),\
                     $(FETCHDIR)/$(editables_dist_name),\
                     $(editables_dist_sum))
endef
$(call gen_fetch_rules,editables,editables_dist_name,fetch_editables_dist)

define xtract_editables
$(call rmrf,$(srcdir)/editables)
$(call untar,$(srcdir)/editables,\
             $(FETCHDIR)/$(editables_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,editables,xtract_editables)

$(call gen_dir_rules,editables)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-editables,stage-wheel)

$(call gen_python_module_rules,stage-editables,editables,$(stagedir))
