################################################################################
# itsdangerous Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

itsdangerous_dist_url  := https://files.pythonhosted.org/packages/7f/a1/d3fb83e7a61fa0c0d3d08ad0a94ddbeff3731c05212617dff3a94e097f08/itsdangerous-2.1.2.tar.gz
itsdangerous_dist_sum  := e4d870a33992b309ed778f403c0c1e098983a693d1165260748bf36385ebfadb583811e05ddd48001a33cf6a4e963b7dd8a8c68919c5b4b86f63621d8869e259
itsdangerous_dist_name := $(notdir $(itsdangerous_dist_url))
itsdangerous_vers      := $(patsubst itsdangerous-%.tar.gz,%,$(itsdangerous_dist_name))
itsdangerous_brief     := Various helpers to pass trusted data to untrusted environment in Python_
itsdangerous_home      := https://palletsprojects.com/p/itsdangerous/

define itsdangerous_desc
itsdangerous provides a module that is a port of the django signing module.
It\'s not directly copied but some changes were applied to make it work better
on its own.

itsdangerous allows web applications to use a key only it knows to
cryptographically sign data and hand it over to someone else (e.g. a user).
When it gets the data back it can easily ensure that nobody tampered with it.
endef

define fetch_itsdangerous_dist
$(call download_csum,$(itsdangerous_dist_url),\
                     $(itsdangerous_dist_name),\
                     $(itsdangerous_dist_sum))
endef
$(call gen_fetch_rules,itsdangerous,\
                       itsdangerous_dist_name,\
                       fetch_itsdangerous_dist)

define xtract_itsdangerous
$(call rmrf,$(srcdir)/itsdangerous)
$(call untar,$(srcdir)/itsdangerous,\
             $(FETCHDIR)/$(itsdangerous_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,itsdangerous,xtract_itsdangerous)

$(call gen_dir_rules,itsdangerous)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-itsdangerous,stage-wheel)

$(call gen_python_module_rules,stage-itsdangerous,itsdangerous,$(stagedir))
