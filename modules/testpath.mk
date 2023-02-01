# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

testpath_dist_url  := https://files.pythonhosted.org/packages/08/ad/a3e7d580902f57e31d2181563fc4088894692bb6ef79b816344f27719cdc/testpath-0.6.0.tar.gz
testpath_dist_sum  := 2f1b97e6442c02681ebe01bd84f531028a7caea1af3825000f52345c30285e0f
testpath_dist_name := $(notdir $(testpath_dist_url))

define fetch_testpath_dist
$(call _download,$(testpath_dist_url),$(FETCHDIR)/$(testpath_dist_name).tmp)
cat $(FETCHDIR)/$(testpath_dist_name).tmp | \
	sha256sum --check --status <(echo "$(testpath_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(testpath_dist_name).tmp,\
          $(FETCHDIR)/$(testpath_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(testpath_dist_name)'
endef

# As fetch_testpath_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(testpath_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,testpath,testpath_dist_name,fetch_testpath_dist)

define xtract_testpath
$(call rmrf,$(srcdir)/testpath)
$(call untar,$(srcdir)/testpath,\
             $(FETCHDIR)/$(testpath_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,testpath,xtract_testpath)

$(call gen_dir_rules,testpath)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-testpath,stage-flit_core)

$(call gen_python_module_rules,stage-testpath,testpath,$(stagedir))
