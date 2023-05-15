################################################################################
# Flask Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

flask_dist_url  := https://files.pythonhosted.org/packages/69/b6/53cfa30eed5aa7343daff36622843688ba8c6fe9829bb2b92e193ab1163f/Flask-2.2.2.tar.gz
flask_dist_sum  := d330398829cb0393e07a4dcf495a3939f0e8f7962c0a517fc866d333425dffe1ce8fd26e39a40445259028d46eff4566e97b3f5eba0d6bddf14b9d7bac138945
flask_dist_name := $(subst F,f,$(notdir $(flask_dist_url)))
flask_vers      := $(patsubst flask-%.tar.gz,%,$(flask_dist_name))
flask_brief     := Micro web framework based on Werkzeug_ and :ref:`Jinja2 <jinja>`
flask_home      := https://palletsprojects.com/p/flask

define flask_desc
Flask is a micro web framework for Python_ based on Werkzeug_,
:ref:`Jinja2 <jinja>` and good intentions.
endef

define fetch_flask_dist
$(call download_csum,$(flask_dist_url),\
                     $(flask_dist_name),\
                     $(flask_dist_sum))
endef
$(call gen_fetch_rules,flask,flask_dist_name,fetch_flask_dist)

define xtract_flask
$(call rmrf,$(srcdir)/flask)
$(call untar,$(srcdir)/flask,\
             $(FETCHDIR)/$(flask_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flask,xtract_flask)

$(call gen_dir_rules,flask)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flask,\
                stage-click stage-itsdangerous stage-jinja2 stage-werkzeug)

$(call gen_python_module_rules,stage-flask,flask,$(stagedir))
