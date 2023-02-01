# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pathspec_dist_url  := https://files.pythonhosted.org/packages/32/1a/6baf904503c3e943cae9605c9c88a43b964dea5b59785cf956091b341b08/pathspec-0.10.3.tar.gz
pathspec_dist_sum  := 56200de4077d9d0791465aa9095a01d421861e405b5096955051deefd697d6f6
pathspec_dist_name := $(notdir $(pathspec_dist_url))

define fetch_pathspec_dist
$(call _download,$(pathspec_dist_url),$(FETCHDIR)/$(pathspec_dist_name).tmp)
cat $(FETCHDIR)/$(pathspec_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pathspec_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pathspec_dist_name).tmp,\
          $(FETCHDIR)/$(pathspec_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pathspec_dist_name)'
endef

# As fetch_pathspec_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pathspec_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pathspec,pathspec_dist_name,fetch_pathspec_dist)

define xtract_pathspec
$(call rmrf,$(srcdir)/pathspec)
$(call untar,$(srcdir)/pathspec,\
             $(FETCHDIR)/$(pathspec_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pathspec,xtract_pathspec)

$(call gen_dir_rules,pathspec)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pathspec,stage-wheel)

$(call gen_python_module_rules,stage-pathspec,pathspec,$(stagedir))
