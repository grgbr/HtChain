################################################################################
# pysocks Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pysocks_dist_url  := https://files.pythonhosted.org/packages/bd/11/293dd436aea955d45fc4e8a35b6ae7270f5b8e00b53cf6c024c83b657a11/PySocks-1.7.1.tar.gz
pysocks_dist_sum  := cef4a5ce8c67fb485644696a23bf68a721db47f3211212de2d4431eaf9ebd26077dd5a06f6dfa7fde2dcb9d7c1ed551facd014e999929cb4d7b504972c464016
pysocks_vers      := $(patsubst PySocks-%.tar.gz,%,$(notdir $(pysocks_dist_url)))
pysocks_dist_name := pysocks-$(pysocks_vers).tar.gz
pysocks_brief     := Python_ socks client module
pysocks_home      := https://github.com/Anorov/PySocks

define pysocks_desc
This module was designed to allow developers of Python_ software that uses the
Internet or another TCP/IP-based network to add support for connection through a
SOCKS proxy server with as much ease as possible.
endef

define fetch_pysocks_dist
$(call download_csum,$(pysocks_dist_url),\
                     $(FETCHDIR)/$(pysocks_dist_name),\
                     $(pysocks_dist_sum))
endef
$(call gen_fetch_rules,pysocks,pysocks_dist_name,fetch_pysocks_dist)

define xtract_pysocks
$(call rmrf,$(srcdir)/pysocks)
$(call untar,$(srcdir)/pysocks,\
             $(FETCHDIR)/$(pysocks_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pysocks,xtract_pysocks)

$(call gen_dir_rules,pysocks)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pysocks,stage-wheel)

$(call gen_python_module_rules,stage-pysocks,pysocks,$(stagedir))
