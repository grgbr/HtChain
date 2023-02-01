# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

hatchling_dist_url  := https://files.pythonhosted.org/packages/f5/ea/3ed5a7ecdd8a8f7e84cffd3b5ec24279a09ce2694c218ff922c35c6f1a77/hatchling-1.12.2.tar.gz
hatchling_dist_sum  := 8a6d719d96653a0f3901072b12710c9c3cc934f9061b443775c6789b45333495
hatchling_dist_name := $(notdir $(hatchling_dist_url))

define fetch_hatchling_dist
$(call _download,$(hatchling_dist_url),$(FETCHDIR)/$(hatchling_dist_name).tmp)
cat $(FETCHDIR)/$(hatchling_dist_name).tmp | \
	sha256sum --check --status <(echo "$(hatchling_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(hatchling_dist_name).tmp,\
          $(FETCHDIR)/$(hatchling_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(hatchling_dist_name)'
endef

# As fetch_hatchling_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(hatchling_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,hatchling,hatchling_dist_name,fetch_hatchling_dist)

define xtract_hatchling
$(call rmrf,$(srcdir)/hatchling)
$(call untar,$(srcdir)/hatchling,\
             $(FETCHDIR)/$(hatchling_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,hatchling,xtract_hatchling)

$(call gen_dir_rules,hatchling)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-hatchling,stage-editables \
                                stage-pathspec \
                                stage-pluggy \
                                stage-tomli \
                                stage-packaging)

$(call gen_python_module_rules,stage-hatchling,hatchling,$(stagedir))
