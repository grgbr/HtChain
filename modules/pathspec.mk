################################################################################
# pathspec Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pathspec_dist_url  := https://files.pythonhosted.org/packages/32/1a/6baf904503c3e943cae9605c9c88a43b964dea5b59785cf956091b341b08/pathspec-0.10.3.tar.gz
pathspec_dist_sum  := d0876374ab20d3624f1ba522de30472e401220ef3b269df9ea2e20526d5abddb8fd19866b0e3405a4746beb3a4b4b6f21ada4da5b7292a46febd6d418829e0f3
pathspec_dist_name := $(notdir $(pathspec_dist_url))
pathspec_vers      := $(patsubst pathspec-%.tar.gz,%,$(pathspec_dist_name))
pathspec_brief     := Python_ utility for gitignore style pattern matching of file paths
pathspec_home      := https://github.com/cpburnz/python-path-specification

define pathspec_desc
Pathspec is a utility library for pattern matching of file paths.  So far this
only includes Git\'s wildmatch pattern matching which itself is derived from
Rsync's wildmatch. Git uses wildmatch for its gitignore files.
endef

define fetch_pathspec_dist
$(call download_csum,$(pathspec_dist_url),\
                     $(FETCHDIR)/$(pathspec_dist_name),\
                     $(pathspec_dist_sum))
endef
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
