# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

freezegun_dist_url  := https://files.pythonhosted.org/packages/1d/97/002ac49ec52858538b4aa6f6831f83c2af562c17340bdf6043be695f39ac/freezegun-1.2.2.tar.gz
freezegun_dist_sum  := cd22d1ba06941384410cd967d8a99d5ae2442f57dfafeff2fda5de8dc5c05446
freezegun_dist_name := $(notdir $(freezegun_dist_url))

define fetch_freezegun_dist
$(call _download,$(freezegun_dist_url),$(FETCHDIR)/$(freezegun_dist_name).tmp)
cat $(FETCHDIR)/$(freezegun_dist_name).tmp | \
	sha256sum --check --status <(echo "$(freezegun_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(freezegun_dist_name).tmp,\
          $(FETCHDIR)/$(freezegun_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(freezegun_dist_name)'
endef

# As fetch_freezegun_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(freezegun_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,freezegun,freezegun_dist_name,fetch_freezegun_dist)

define xtract_freezegun
$(call rmrf,$(srcdir)/freezegun)
$(call untar,$(srcdir)/freezegun,\
             $(FETCHDIR)/$(freezegun_dist_name),\
             --strip-components=1)
cd $(srcdir)/freezegun && \
patch -p1 < $(PATCHDIR)/freezegun-1.2.2-000-fix_helper_static_method_call.patch
endef
$(call gen_xtract_rules,freezegun,xtract_freezegun)

$(call gen_dir_rules,freezegun)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-freezegun,stage-python-dateutil)

$(call gen_python_module_rules,stage-freezegun,freezegun,$(stagedir))
