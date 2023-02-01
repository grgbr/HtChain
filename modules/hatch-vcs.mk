# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

hatch-vcs_dist_url  := https://files.pythonhosted.org/packages/04/33/b68d68e532392d938472d16a03e4ce0ccd749ea31b42d18f8baa6547cbfd/hatch_vcs-0.3.0.tar.gz
hatch-vcs_dist_sum  := cec5107cfce482c67f8bc96f18bbc320c9aa0d068180e14ad317bbee5a153fee
hatch-vcs_dist_name := $(notdir $(hatch-vcs_dist_url))

define fetch_hatch-vcs_dist
$(call _download,$(hatch-vcs_dist_url),$(FETCHDIR)/$(hatch-vcs_dist_name).tmp)
cat $(FETCHDIR)/$(hatch-vcs_dist_name).tmp | \
	sha256sum --check --status <(echo "$(hatch-vcs_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(hatch-vcs_dist_name).tmp,\
          $(FETCHDIR)/$(hatch-vcs_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(hatch-vcs_dist_name)'
endef

# As fetch_hatch-vcs_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(hatch-vcs_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,hatch-vcs,hatch-vcs_dist_name,fetch_hatch-vcs_dist)

define xtract_hatch-vcs
$(call rmrf,$(srcdir)/hatch-vcs)
$(call untar,$(srcdir)/hatch-vcs,\
             $(FETCHDIR)/$(hatch-vcs_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,hatch-vcs,xtract_hatch-vcs)

$(call gen_dir_rules,hatch-vcs)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-hatch-vcs,stage-hatchling stage-setuptools-scm)

$(call gen_python_module_rules,stage-hatch-vcs,hatch-vcs,$(stagedir))
