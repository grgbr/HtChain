################################################################################
# execnet Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

execnet_dist_url  := https://files.pythonhosted.org/packages/7a/3c/b5ac9fc61e1e559ced3e40bf5b518a4142536b34eb274aa50dff29cb89f5/execnet-1.9.0.tar.gz
execnet_dist_sum  := d425e7b6f3708efecb5dfa2c36a837cb55f2c32cf2ec0c1dc11cd1ca6ea614d119d04908b84dd5a3593c87db35e71fee202f843665c853ac3538479f60c83d60
execnet_dist_name := $(notdir $(execnet_dist_url))
execnet_vers      := $(patsubst execnet-%.tar.gz,%,$(execnet_dist_name))
execnet_brief     := Rapid multi-Python deployment
execnet_home      := https://execnet.readthedocs.io/en/latest/

define execnet_desc
execnet provides carefully tested means to ad-hoc interact with Python_
interpreters across version, platform and network barriers. It provides a
minimal and fast API targeting the following uses:

* distribute tasks to local or remote CPUs;
* write and deploy hybrid multi-process applications;
* write scripts to administer a bunch of exec environments.
endef

define fetch_execnet_dist
$(call download_csum,$(execnet_dist_url),\
                     $(FETCHDIR)/$(execnet_dist_name),\
                     $(execnet_dist_sum))
endef
$(call gen_fetch_rules,execnet,execnet_dist_name,fetch_execnet_dist)

define xtract_execnet
$(call rmrf,$(srcdir)/execnet)
$(call untar,$(srcdir)/execnet,\
             $(FETCHDIR)/$(execnet_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,execnet,xtract_execnet)

$(call gen_dir_rules,execnet)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-execnet,stage-python)

$(call gen_python_module_rules,stage-execnet,execnet,$(stagedir))
