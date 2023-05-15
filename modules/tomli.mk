################################################################################
# tomli Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

tomli_dist_url  := https://files.pythonhosted.org/packages/c0/3f/d7af728f075fb08564c5949a9c95e44352e23dee646869fa104a3b2060a3/tomli-2.0.1.tar.gz
tomli_dist_sum  := fd410039e255e2b3359e999d69a5a2d38b9b89b77e8557f734f2621dfbd5e1207e13aecc11589197ec22594c022f07f41b4cfe486a3a719281a595c95fd19ecf
tomli_dist_name := $(notdir $(tomli_dist_url))
tomli_vers      := $(patsubst tomli-%.tar.gz,%,$(tomli_dist_name))
tomli_brief     := A lil\' TOML parser for Python_
tomli_home      := https://github.com/hukkin/tomli

define tomli_desc
Tomli is a Python_ library for parsing `TOML <https://toml.io/>`_.
Tomli is fully compatible with `TOML v1.0.0 <https://toml.io/en/v1.0.0>`_.
endef

define fetch_tomli_dist
$(call download_csum,$(tomli_dist_url),\
                     $(tomli_dist_name),\
                     $(tomli_dist_sum))
endef
$(call gen_fetch_rules,tomli,tomli_dist_name,fetch_tomli_dist)

define xtract_tomli
$(call rmrf,$(srcdir)/tomli)
$(call untar,$(srcdir)/tomli,\
             $(FETCHDIR)/$(tomli_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,tomli,xtract_tomli)

$(call gen_dir_rules,tomli)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-tomli,stage-flit_core)

$(call gen_python_module_rules,stage-tomli,tomli,$(stagedir))
