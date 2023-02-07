# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
#
# Required to build some python modules from source.

setuptools_dist_url  := https://files.pythonhosted.org/packages/3c/7b/00030a938499c8f8345be02ab5b7d748d359ea59c2f020b7b0a21b82f832/setuptools-66.1.1.tar.gz
setuptools_dist_sum  := ac4008d396bc9cd983ea483cb7139c0240a07bbc74ffb6232fceffedc6cf03a8
setuptools_dist_name := $(notdir $(setuptools_dist_url))

define fetch_setuptools_dist
$(call _download,$(setuptools_dist_url),$(FETCHDIR)/$(setuptools_dist_name).tmp)
cat $(FETCHDIR)/$(setuptools_dist_name).tmp | \
	sha256sum --check --status <(echo "$(setuptools_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(setuptools_dist_name).tmp,\
          $(FETCHDIR)/$(setuptools_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(setuptools_dist_name)'
endef

# As fetch_setuptools_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(setuptools_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,setuptools,setuptools_dist_name,fetch_setuptools_dist)

define xtract_setuptools
$(call rmrf,$(srcdir)/setuptools)
$(call untar,$(srcdir)/setuptools,\
             $(FETCHDIR)/$(setuptools_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,setuptools,xtract_setuptools)

$(call gen_dir_rules,setuptools)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-setuptools,stage-wheel)

$(call gen_python_module_rules,stage-setuptools,\
                               setuptools,\
                               $(stagedir))
