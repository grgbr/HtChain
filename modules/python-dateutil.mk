# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

python-dateutil_dist_url  := https://files.pythonhosted.org/packages/4c/c4/13b4776ea2d76c115c1d1b84579f3764ee6d57204f6be27119f13a61d0a9/python-dateutil-2.8.2.tar.gz
python-dateutil_dist_sum  := 0123cacc1627ae19ddf3c27a5de5bd67ee4586fbdd6440d9748f8abb483d3e86
python-dateutil_dist_name := $(notdir $(python-dateutil_dist_url))

define fetch_python-dateutil_dist
$(call _download,$(python-dateutil_dist_url),\
                 $(FETCHDIR)/$(python-dateutil_dist_name).tmp)
cat $(FETCHDIR)/$(python-dateutil_dist_name).tmp | \
	sha256sum --check --status <(echo "$(python-dateutil_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(python-dateutil_dist_name).tmp,\
          $(FETCHDIR)/$(python-dateutil_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(python-dateutil_dist_name)'
endef

# As fetch_python-dateutil_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(python-dateutil_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,python-dateutil,python-dateutil_dist_name,fetch_python-dateutil_dist)

define xtract_python-dateutil
$(call rmrf,$(srcdir)/python-dateutil)
$(call untar,$(srcdir)/python-dateutil,\
             $(FETCHDIR)/$(python-dateutil_dist_name),\
             --strip-components=1)
cd $(srcdir)/python-dateutil && \
patch -p1 < $(PATCHDIR)/python-dateutil-2.8.2-000-remove_zoneinfo.patch
endef
$(call gen_xtract_rules,python-dateutil,xtract_python-dateutil)

$(call gen_dir_rules,python-dateutil)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-python-dateutil,stage-six stage-wheel)

check_stage-python-dateutil = $(call python-dateutil_check_cmds,\
                                     stage-python-dateutil)
$(call gen_python_module_rules,stage-python-dateutil,\
                               python-dateutil,\
                               $(stagedir))
