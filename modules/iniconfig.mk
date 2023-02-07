################################################################################
# iniconfig Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

iniconfig_dist_url  := https://files.pythonhosted.org/packages/d7/4b/cbd8e699e64a6f16ca3a8220661b5f83792b3017d0f79807cb8708d33913/iniconfig-2.0.0.tar.gz
iniconfig_dist_sum  := f0287115595a1ba074c5c77c3f7840efc2fef6c95c5ff3deaaf278c78b328f92187c358d5dd074b62c033db47952d99fc6d5164d4a48c81ba2c53d571eb76090
iniconfig_dist_name := $(notdir $(iniconfig_dist_url))
iniconfig_vers      := $(patsubst iniconfig-%.tar.gz,%,$(iniconfig_dist_name))
iniconfig_brief     := Brain-dead simple parsing of ini files in Python_
iniconfig_home      := https://github.com/pytest-dev/iniconfig

define iniconfig_desc
iniconfig is a small and simple INI-file parser module having a unique set of
features:

* tested against Python2.4 across to Python3.2, Jython, PyPy
* maintains order of sections and entries
* supports multi-line values with or without line-continuations
* supports ``#`` comments everywhere
* raises errors with proper line-numbers
* no bells and whistles like automatic substitutions
* iniconfig raises an Error if two sections have the same name.
endef

define fetch_iniconfig_dist
$(call download_csum,$(iniconfig_dist_url),\
                     $(FETCHDIR)/$(iniconfig_dist_name),\
                     $(iniconfig_dist_sum))
endef
$(call gen_fetch_rules,iniconfig,iniconfig_dist_name,fetch_iniconfig_dist)

define xtract_iniconfig
$(call rmrf,$(srcdir)/iniconfig)
$(call untar,$(srcdir)/iniconfig,\
             $(FETCHDIR)/$(iniconfig_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,iniconfig,xtract_iniconfig)

$(call gen_dir_rules,iniconfig)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-iniconfig,stage-hatch-vcs)

$(call gen_python_module_rules,stage-iniconfig,iniconfig,$(stagedir))
