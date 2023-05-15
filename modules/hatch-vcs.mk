################################################################################
# hatch-vcs Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

hatch-vcs_dist_url  := https://files.pythonhosted.org/packages/04/33/b68d68e532392d938472d16a03e4ce0ccd749ea31b42d18f8baa6547cbfd/hatch_vcs-0.3.0.tar.gz
hatch-vcs_dist_sum  := 06a80e90b45b1316b42845808d04d00d00356f42d32f02d934db0aa9df05efa2f692413709e0dd5465f447829f2f5410110fbbeb826bafdea1f1014e3096e056
hatch-vcs_dist_name := $(notdir $(hatch-vcs_dist_url))
hatch-vcs_vers      := $(patsubst hatch-vcs-%.tar.xz,%,$(hatch-vcs_dist_name))
hatch-vcs_brief     := `Hatch <https://hatch.pypa.io/>`_ plugin for versioning from VCS
hatch-vcs_home      := https://github.com/ofek/hatch-vcs

define hatch-vcs_desc
This provides a plugin for `Hatch <https://hatch.pypa.io/>`_ that uses
your preferred version control system (like Git) to determine project versions.

It may be required to build a Python_ module from source.
endef

define fetch_hatch-vcs_dist
$(call download_csum,$(hatch-vcs_dist_url),\
                     $(hatch-vcs_dist_name),\
                     $(hatch-vcs_dist_sum))
endef
$(call gen_fetch_rules,hatch-vcs,hatch-vcs_dist_name,fetch_hatch-vcs_dist)

define xtract_hatch-vcs
$(call rmrf,$(srcdir)/hatch-vcs)
$(call untar,$(srcdir)/hatch-vcs,\
             $(FETCHDIR)/$(hatch-vcs_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,hatch-vcs,xtract_hatch-vcs)

$(call gen_dir_rules,hatch-vcs)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-hatch-vcs,stage-hatchling stage-setuptools-scm)

$(call gen_python_module_rules,stage-hatch-vcs,hatch-vcs,$(stagedir))
