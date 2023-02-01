# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

semantic-version_dist_url  := https://files.pythonhosted.org/packages/7d/31/f2289ce78b9b473d582568c234e104d2a342fd658cc288a7553d83bb8595/semantic_version-2.10.0.tar.gz
semantic-version_dist_sum  := bdabb6d336998cbb378d4b9db3a4b56a1e3235701dc05ea2690d9a997ed5041c
semantic-version_dist_name := $(notdir $(semantic-version_dist_url))

define fetch_semantic-version_dist
$(call _download,$(semantic-version_dist_url),\
                 $(FETCHDIR)/$(semantic-version_dist_name).tmp)
cat $(FETCHDIR)/$(semantic-version_dist_name).tmp | \
	sha256sum --check --status <(echo "$(semantic-version_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(semantic-version_dist_name).tmp,\
          $(FETCHDIR)/$(semantic-version_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(semantic-version_dist_name)'
endef

# As fetch_semantic-version_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(semantic-version_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,semantic-version,\
                       semantic-version_dist_name,\
                       fetch_semantic-version_dist)

define xtract_semantic-version
$(call rmrf,$(srcdir)/semantic-version)
$(call untar,$(srcdir)/semantic-version,\
             $(FETCHDIR)/$(semantic-version_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,semantic-version,xtract_semantic-version)

$(call gen_dir_rules,semantic-version)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-semantic-version,stage-python)

$(call gen_python_module_rules,stage-semantic-version,\
                               semantic-version,\
                               $(stagedir))
