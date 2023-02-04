################################################################################
# click modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

click_dist_url  := https://files.pythonhosted.org/packages/59/87/84326af34517fca8c58418d148f2403df25303e02736832403587318e9e8/click-8.1.3.tar.gz
click_dist_sum  := be5b0c8b72ef7c10854f31406668ca4d6f826381deff10bb6a87a406166c09af97e2165f1327094d96abade15efb872892af37f20fdbc855b659cb2c7bd2f2c5
click_dist_name := $(notdir $(click_dist_url))
click_vers      := $(patsubst click-%.tar.gz,%,$(click_dist_name))
click_brief     := Wrapper around Python_ optparse for command line utilities
click_home      := https://palletsprojects.com/p/click/

define click_desc
Click is a Python_ package for creating beautiful command line interfaces in a
composable way with as little code as necessary.  It\'s the "Command Line
Interface Creation Kit".  It's highly configurable but comes with sensible
defaults out of the box.

It aims to make the process of writing command line tools quick and fun while
also preventing any frustration caused by the inability to implement an intended
CLI API.
endef

define fetch_click_dist
$(call download_csum,$(click_dist_url),\
                     $(FETCHDIR)/$(click_dist_name),\
                     $(click_dist_sum))
endef
$(call gen_fetch_rules,click,click_dist_name,fetch_click_dist)

define xtract_click
$(call rmrf,$(srcdir)/click)
$(call untar,$(srcdir)/click,\
             $(FETCHDIR)/$(click_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,click,xtract_click)

$(call gen_dir_rules,click)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-click,stage-python)

$(call gen_python_module_rules,stage-click,click,$(stagedir))
