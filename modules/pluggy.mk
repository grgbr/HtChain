################################################################################
# pluggy Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pluggy_dist_url  := https://files.pythonhosted.org/packages/a1/16/db2d7de3474b6e37cbb9c008965ee63835bba517e22cdb8c35b5116b5ce1/pluggy-1.0.0.tar.gz
pluggy_dist_sum  := cf0bcbb4330c24ce473614befa19548f33fb39fa0ad094e1eae786202d7adadc28e16499f80ab96b630091765404ca5c5b6f9a55bc605e03514d8ab50cf9ae00
pluggy_dist_name := $(notdir $(pluggy_dist_url))
pluggy_vers      := $(patsubst pluggy-%.tar.gz,%,$(pluggy_dist_name))
pluggy_brief     := Plugin and hook calling mechanisms for Python_
pluggy_home      := https://github.com/pytest-dev/pluggy

define pluggy_desc
pluggy is the cristallized core of plugin management as used by some 150 plugins
for pytest_.
endef

define fetch_pluggy_dist
$(call download_csum,$(pluggy_dist_url),\
                     $(FETCHDIR)/$(pluggy_dist_name),\
                     $(pluggy_dist_sum))
endef
$(call gen_fetch_rules,pluggy,pluggy_dist_name,fetch_pluggy_dist)

define xtract_pluggy
$(call rmrf,$(srcdir)/pluggy)
$(call untar,$(srcdir)/pluggy,\
             $(FETCHDIR)/$(pluggy_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pluggy,xtract_pluggy)

$(call gen_dir_rules,pluggy)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pluggy,stage-wheel)

$(call gen_python_module_rules,stage-pluggy,pluggy,$(stagedir))
