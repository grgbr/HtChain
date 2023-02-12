################################################################################
# trustme Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

trustme_dist_url  := https://files.pythonhosted.org/packages/34/8e/66203d0c8c4557db28772678359e0878610624db8438b1ed9361ceeaad1d/trustme-0.9.0.tar.gz
trustme_dist_sum  := f0d983a4c52374f178c0bf96f758fdb5f132e7f7c4bac187c84fbc8dc82dc36d6c801c340bf8871e872178f7b2ac66d6159b5462d073beec9a13a086f64b58b7
trustme_dist_name := $(notdir $(trustme_dist_url))
trustme_vers      := $(patsubst trustme-%.tar.gz,%,$(trustme_dist_name))
trustme_brief     := Fake certificate authority for test use in Python_
trustme_home      := https://github.com/python-trio/trustme

define trustme_desc
trustme is a tiny Python_ package that gives you a fake certificate authority
(CA) that you can use to generate fake TLS certificates to use in tests. Its
only useful purpose is as a dependency of test suites.
endef

define fetch_trustme_dist
$(call download_csum,$(trustme_dist_url),\
                     $(FETCHDIR)/$(trustme_dist_name),\
                     $(trustme_dist_sum))
endef
$(call gen_fetch_rules,trustme,trustme_dist_name,fetch_trustme_dist)

define xtract_trustme
$(call rmrf,$(srcdir)/trustme)
$(call untar,$(srcdir)/trustme,\
             $(FETCHDIR)/$(trustme_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,trustme,xtract_trustme)

$(call gen_dir_rules,trustme)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-trustme,stage-cryptography stage-idna)

$(call gen_python_module_rules,stage-trustme,trustme,$(stagedir))
