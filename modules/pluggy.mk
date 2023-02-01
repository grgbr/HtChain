# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pluggy_dist_url  := https://files.pythonhosted.org/packages/a1/16/db2d7de3474b6e37cbb9c008965ee63835bba517e22cdb8c35b5116b5ce1/pluggy-1.0.0.tar.gz
pluggy_dist_sum  := 4224373bacce55f955a878bf9cfa763c1e360858e330072059e10bad68531159
pluggy_dist_name := $(notdir $(pluggy_dist_url))

define fetch_pluggy_dist
$(call _download,$(pluggy_dist_url),$(FETCHDIR)/$(pluggy_dist_name).tmp)
cat $(FETCHDIR)/$(pluggy_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pluggy_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pluggy_dist_name).tmp,\
          $(FETCHDIR)/$(pluggy_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pluggy_dist_name)'
endef

# As fetch_pluggy_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pluggy_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pluggy,pluggy_dist_name,fetch_pluggy_dist)

define xtract_pluggy
$(call rmrf,$(srcdir)/pluggy)
$(call untar,$(srcdir)/pluggy,\
             $(FETCHDIR)/$(pluggy_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pluggy,xtract_pluggy)

$(call gen_dir_rules,pluggy)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pluggy,stage-wheel)

$(call gen_python_module_rules,stage-pluggy,pluggy,$(stagedir))
