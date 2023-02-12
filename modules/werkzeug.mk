################################################################################
# werkzeug Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

werkzeug_dist_url  := https://files.pythonhosted.org/packages/f8/c1/1c8e539f040acd80f844c69a5ef8e2fccdf8b442dabb969e497b55d544e1/Werkzeug-2.2.2.tar.gz
werkzeug_dist_sum  := b37a63ba1d6970b10ba17b87575c2d030ad6c4c00ab50669d678297b9801e319f4f81f98bfc2d89fc2e645c5e192dd81ed2d653c03dbaef06565de0bdac2bcf7
werkzeug_dist_name := $(subst W,w,$(notdir $(werkzeug_dist_url)))
werkzeug_vers      := $(patsubst werkzeug-%.tar.gz,%,$(werkzeug_dist_name))
werkzeug_brief     := Collection of utilities for WSGI applications in Python_
werkzeug_home      := https://palletsprojects.com/p/werkzeug/

define werkzeug_desc
The Web Server Gateway Interface (WSGI) is a standard interface between web
server software and web applications written in Python_.

Werkzeug is a lightweight library for interfacing with WSGI. It features request
and response objects, an interactive debugging system and a powerful URI
dispatcher. Combine with your choice of third party libraries and middleware to
easily create a custom application framework.
endef

define fetch_werkzeug_dist
$(call download_csum,$(werkzeug_dist_url),\
                     $(FETCHDIR)/$(werkzeug_dist_name),\
                     $(werkzeug_dist_sum))
endef
$(call gen_fetch_rules,werkzeug,werkzeug_dist_name,fetch_werkzeug_dist)

define xtract_werkzeug
$(call rmrf,$(srcdir)/werkzeug)
$(call untar,$(srcdir)/werkzeug,\
             $(FETCHDIR)/$(werkzeug_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,werkzeug,xtract_werkzeug)

$(call gen_dir_rules,werkzeug)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-werkzeug,stage-markupsafe)

$(call gen_python_module_rules,stage-werkzeug,werkzeug,$(stagedir))
