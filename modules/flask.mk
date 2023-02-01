# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

flask_dist_url  := https://files.pythonhosted.org/packages/69/b6/53cfa30eed5aa7343daff36622843688ba8c6fe9829bb2b92e193ab1163f/Flask-2.2.2.tar.gz
flask_dist_sum  := 642c450d19c4ad482f96729bd2a8f6d32554aa1e231f4f6b4e7e5264b16cca2b
flask_dist_name := $(notdir $(flask_dist_url))

define fetch_flask_dist
$(call _download,$(flask_dist_url),$(FETCHDIR)/$(flask_dist_name).tmp)
cat $(FETCHDIR)/$(flask_dist_name).tmp | \
	sha256sum --check --status <(echo "$(flask_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(flask_dist_name).tmp,\
          $(FETCHDIR)/$(flask_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(flask_dist_name)'
endef

# As fetch_flask_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(flask_dist_name): SHELL:=/bin/bash
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
