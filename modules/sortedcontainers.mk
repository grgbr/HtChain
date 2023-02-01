# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
#
# No test suite shipped with PyPi distribution...

sortedcontainers_dist_url  := https://files.pythonhosted.org/packages/e8/c4/ba2f8066cceb6f23394729afe52f3bf7adec04bf9ed2c820b39e19299111/sortedcontainers-2.4.0.tar.gz
sortedcontainers_dist_sum  := 25caa5a06cc30b6b83d11423433f65d1f9d76c4c6a0c90e3379eaa43b9bfdb88
sortedcontainers_dist_name := $(notdir $(sortedcontainers_dist_url))

define fetch_sortedcontainers_dist
$(call _download,$(sortedcontainers_dist_url),$(FETCHDIR)/$(sortedcontainers_dist_name).tmp)
cat $(FETCHDIR)/$(sortedcontainers_dist_name).tmp | \
	sha256sum --check --status <(echo "$(sortedcontainers_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sortedcontainers_dist_name).tmp,\
          $(FETCHDIR)/$(sortedcontainers_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sortedcontainers_dist_name)'
endef

# As fetch_sortedcontainers_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sortedcontainers_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,sortedcontainers,\
                       sortedcontainers_dist_name,\
                       fetch_sortedcontainers_dist)

define xtract_sortedcontainers
$(call rmrf,$(srcdir)/sortedcontainers)
$(call untar,$(srcdir)/sortedcontainers,\
             $(FETCHDIR)/$(sortedcontainers_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sortedcontainers,xtract_sortedcontainers)

$(call gen_dir_rules,sortedcontainers)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sortedcontainers,stage-python)

$(call gen_python_module_rules,stage-sortedcontainers,\
                               sortedcontainers,\
                               $(stagedir))
