# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

werkzeug_dist_url  := https://files.pythonhosted.org/packages/f8/c1/1c8e539f040acd80f844c69a5ef8e2fccdf8b442dabb969e497b55d544e1/Werkzeug-2.2.2.tar.gz
werkzeug_dist_sum  := 7ea2d48322cc7c0f8b3a215ed73eabd7b5d75d0b50e31ab006286ccff9e00b8f
werkzeug_dist_name := $(notdir $(werkzeug_dist_url))

define fetch_werkzeug_dist
$(call _download,$(werkzeug_dist_url),$(FETCHDIR)/$(werkzeug_dist_name).tmp)
cat $(FETCHDIR)/$(werkzeug_dist_name).tmp | \
	sha256sum --check --status <(echo "$(werkzeug_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(werkzeug_dist_name).tmp,\
          $(FETCHDIR)/$(werkzeug_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(werkzeug_dist_name)'
endef

# As fetch_werkzeug_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(werkzeug_dist_name): SHELL:=/bin/bash
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
