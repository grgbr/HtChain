# Use version 0.7.12 as 0.7.13 breaks sphinx test_config.py::test_needs_sphinx
# test...

alabaster_dist_url  := https://files.pythonhosted.org/packages/cc/b4/ed8dcb0d67d5cfb7f83c4d5463a7614cb1d078ad7ae890c9143edebbf072/alabaster-0.7.12.tar.gz
alabaster_dist_sum  := e3bfd0c92ce01f08d5e6d9dc1ef0967ca1f54827e08756f4a0ba7be8d3b8bec7f2e53a169b831ff5ce2d2548f7f52c6e518bcc513e49bb3e4c38274293aebbac
alabaster_dist_name := $(notdir $(alabaster_dist_url))
alabaster_vers      := $(patsubst alabaster-%.tar.gz,%,$(alabaster_dist_name))
alabaster_brief     := Theme for the Sphinx_ documentation system
alabaster_home      := https://alabaster.readthedocs.io/

define alabaster_desc
This is a configurable sidebar-enabled theme for the Sphinx_ documentation
system.

This theme is a modified "Kr" Sphinx_ theme from @kennethreitz (especially as
used in his Requests project), which was itself originally based on
@mitsuhiko\'s theme used for Flask & related projects.
endef

define fetch_alabaster_dist
$(call download_csum,$(alabaster_dist_url),\
                     $(FETCHDIR)/$(alabaster_dist_name),\
                     $(alabaster_dist_sum))
endef
$(call gen_fetch_rules,alabaster,alabaster_dist_name,fetch_alabaster_dist)

define xtract_alabaster
$(call rmrf,$(srcdir)/alabaster)
$(call untar,$(srcdir)/alabaster,\
             $(FETCHDIR)/$(alabaster_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,alabaster,xtract_alabaster)

$(call gen_dir_rules,alabaster)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-alabaster,stage-wheel)

$(call gen_python_module_rules,stage-alabaster,\
                               alabaster,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-alabaster,stage-wheel)

$(call gen_python_module_rules,final-alabaster,\
                               alabaster,\
                               $(PREFIX),\
                               $(finaldir))
