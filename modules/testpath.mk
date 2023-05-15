################################################################################
# testpath Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

testpath_dist_url  := https://files.pythonhosted.org/packages/08/ad/a3e7d580902f57e31d2181563fc4088894692bb6ef79b816344f27719cdc/testpath-0.6.0.tar.gz
testpath_dist_sum  := 64ec7ee32ed766e518eabcbb552a0675b2495cac6b94adb2972dd0db97d747146d3a181e8fac59d847dbaaa4f573c349e51a4e3bf3991eb33207bb2176736649
testpath_dist_name := $(notdir $(testpath_dist_url))
testpath_vers      := $(patsubst testpath-%.tar.gz,%,$(testpath_dist_name))
testpath_brief     := Utilities for Python_ code working with files and commands
testpath_home      := https://github.com/jupyter/testpath

define testpath_desc
It contains functions to check things on the filesystem, and tools for mocking
and recording calls to those.
endef

define fetch_testpath_dist
$(call download_csum,$(testpath_dist_url),\
                     $(testpath_dist_name),\
                     $(testpath_dist_sum))
endef
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
