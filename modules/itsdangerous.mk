# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

itsdangerous_dist_url  := https://files.pythonhosted.org/packages/7f/a1/d3fb83e7a61fa0c0d3d08ad0a94ddbeff3731c05212617dff3a94e097f08/itsdangerous-2.1.2.tar.gz
itsdangerous_dist_sum  := 5dbbc68b317e5e42f327f9021763545dc3fc3bfe22e6deb96aaf1fc38874156a
itsdangerous_dist_name := $(notdir $(itsdangerous_dist_url))

define fetch_itsdangerous_dist
$(call _download,$(itsdangerous_dist_url),\
                 $(FETCHDIR)/$(itsdangerous_dist_name).tmp)
cat $(FETCHDIR)/$(itsdangerous_dist_name).tmp | \
	sha256sum --check --status <(echo "$(itsdangerous_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(itsdangerous_dist_name).tmp,\
          $(FETCHDIR)/$(itsdangerous_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(itsdangerous_dist_name)'
endef

# As fetch_itsdangerous_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(itsdangerous_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,itsdangerous,\
                       itsdangerous_dist_name,\
                       fetch_itsdangerous_dist)

define xtract_itsdangerous
$(call rmrf,$(srcdir)/itsdangerous)
$(call untar,$(srcdir)/itsdangerous,\
             $(FETCHDIR)/$(itsdangerous_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,itsdangerous,xtract_itsdangerous)

$(call gen_dir_rules,itsdangerous)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-itsdangerous,stage-python)

$(call gen_python_module_rules,stage-itsdangerous,itsdangerous,$(stagedir))
