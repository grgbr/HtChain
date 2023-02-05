################################################################################
# acl modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

hatchling_dist_url  := https://files.pythonhosted.org/packages/f5/ea/3ed5a7ecdd8a8f7e84cffd3b5ec24279a09ce2694c218ff922c35c6f1a77/hatchling-1.12.2.tar.gz
hatchling_dist_sum  := 4cac57d8485dde72e5e1c60d30583f631226ff938f3eb657643602e3f19eff85b35f273a4a7890fd103bb4ade7cd2c6dd698c626779e544cfed80c59ed825f2f
hatchling_dist_name := $(notdir $(hatchling_dist_url))
hatchling_vers      := $(patsubst hatchling-%.tar.gz,%,$(hatchling_dist_name))
hatchling_brief     := Python_ package build backend used by `Hatch <https://hatch.pypa.io/>`_
hatchling_home      := https://hatch.pypa.io/

define hatchling_desc
This is the extensible, standards compliant build backend used by `Hatch <https://hatch.pypa.io/>`_.

It may be required to build a Python_ module from source.
endef

define fetch_hatchling_dist
$(call download_csum,$(hatchling_dist_url),\
                     $(FETCHDIR)/$(hatchling_dist_name),\
                     $(hatchling_dist_sum))
endef
$(call gen_fetch_rules,hatchling,hatchling_dist_name,fetch_hatchling_dist)

define xtract_hatchling
$(call rmrf,$(srcdir)/hatchling)
$(call untar,$(srcdir)/hatchling,\
             $(FETCHDIR)/$(hatchling_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,hatchling,xtract_hatchling)

$(call gen_dir_rules,hatchling)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-hatchling,stage-editables \
                                stage-pathspec \
                                stage-pluggy \
                                stage-tomli \
                                stage-packaging)

$(call gen_python_module_rules,stage-hatchling,hatchling,$(stagedir))
