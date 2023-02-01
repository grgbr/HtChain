# Use version 0.7.12 as 0.7.13 breaks sphinx test_config.py::test_needs_sphinx
# test...

alabaster_dist_url  := https://files.pythonhosted.org/packages/cc/b4/ed8dcb0d67d5cfb7f83c4d5463a7614cb1d078ad7ae890c9143edebbf072/alabaster-0.7.12.tar.gz
alabaster_dist_sum  := a661d72d58e6ea8a57f7a86e37d86716863ee5e92788398526d58b26a4e4dc02
alabaster_dist_name := $(notdir $(alabaster_dist_url))
alabaster_vers      := $(patsubst alabaster-%.tar.gz,%,$(alabaster_dist_name))
alabaster_brief     := Theme for the Sphinx documentation system
alabaster_home      := https://alabaster.readthedocs.io

define alabaster_desc
This is a configurable sidebar-enabled theme for the Sphinx documentation
system.

This theme is a modified "Kr" Sphinx theme from @kennethreitz (especially as
used in his Requests project), which was itself originally based on
@mitsuhiko\'s theme used for Flask & related projects.
endef

define fetch_alabaster_dist
$(call _download,$(alabaster_dist_url),$(FETCHDIR)/$(alabaster_dist_name).tmp)
cat $(FETCHDIR)/$(alabaster_dist_name).tmp | \
	sha256sum --check --status <(echo "$(alabaster_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(alabaster_dist_name).tmp,\
          $(FETCHDIR)/$(alabaster_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(alabaster_dist_name)'
endef

# As fetch_alabaster_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(alabaster_dist_name): SHELL:=/bin/bash
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

$(call gen_deps,stage-alabaster,stage-python)

$(call gen_python_module_rules,stage-alabaster,\
                               alabaster,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-alabaster,stage-python)

$(call gen_python_module_rules,final-alabaster,\
                               alabaster,\
                               $(PREFIX),\
                               $(finaldir))
