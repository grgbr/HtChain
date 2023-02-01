# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

readthedocs-sphinx-ext_dist_url  := https://files.pythonhosted.org/packages/f3/55/9e440437dcf29ad69963247050872acb981e0ab728c3cc2405b66d124593/readthedocs-sphinx-ext-2.2.0.tar.gz
readthedocs-sphinx-ext_dist_sum  := e5effcd825816111a377ab7a897b819215138f8e5e8acc86f99218328f957240
readthedocs-sphinx-ext_dist_name := $(notdir $(readthedocs-sphinx-ext_dist_url))

define fetch_readthedocs-sphinx-ext_dist
$(call _download,$(readthedocs-sphinx-ext_dist_url),\
                 $(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name).tmp)
cat $(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name).tmp | \
	sha256sum --check --status <(echo "$(readthedocs-sphinx-ext_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name).tmp,\
          $(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name)'
endef

# As fetch_readthedocs-sphinx-ext_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,readthedocs-sphinx-ext,\
                       readthedocs-sphinx-ext_dist_name,\
                       fetch_readthedocs-sphinx-ext_dist)

define xtract_readthedocs-sphinx-ext
$(call rmrf,$(srcdir)/readthedocs-sphinx-ext)
$(call untar,$(srcdir)/readthedocs-sphinx-ext,\
             $(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,readthedocs-sphinx-ext,xtract_readthedocs-sphinx-ext)

$(call gen_dir_rules,readthedocs-sphinx-ext)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-readthedocs-sphinx-ext,\
                stage-requests stage-jinja2 stage-packaging)

$(call gen_python_module_rules,stage-readthedocs-sphinx-ext,\
                               readthedocs-sphinx-ext,$(stagedir))
