################################################################################
# pretend Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pretend_dist_url  := https://files.pythonhosted.org/packages/3c/f8/7c86fd40c9e83deb10891a60d2dcb1af0b3b38064d72ebdb12486acc824f/pretend-1.0.9.tar.gz
pretend_dist_sum  := 25dfbc4035f7ec7088be40846847620495656ddedbc8a0111ca36e6f6cbd59f14b974403d60827363db3f11bedd38a91e84f9d494f7715e6e8cdb0abfa690a87
pretend_dist_name := $(notdir $(pretend_dist_url))
pretend_vers      := $(patsubst pretend-%.tar.gz,%,$(pretend_dist_name))
pretend_brief     := Python_ library for stubbing
pretend_home      := https://github.com/alex/pretend

define pretend_desc
Pretend is a library to make stubbing with Python_ easier.

Stubbing is a technique for writing tests. You may hear the term mixed up with
mocks, fakes, or doubles. Basically a stub is an object that returns pre-canned
responses, rather than doing any computation.
endef

define fetch_pretend_dist
$(call download_csum,$(pretend_dist_url),\
                     $(FETCHDIR)/$(pretend_dist_name),\
                     $(pretend_dist_sum))
endef
$(call gen_fetch_rules,pretend,pretend_dist_name,fetch_pretend_dist)

define xtract_pretend
$(call rmrf,$(srcdir)/pretend)
$(call untar,$(srcdir)/pretend,\
             $(FETCHDIR)/$(pretend_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pretend,xtract_pretend)

$(call gen_dir_rules,pretend)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pretend,stage-wheel)

$(call gen_python_module_rules,stage-pretend,pretend,$(stagedir))
