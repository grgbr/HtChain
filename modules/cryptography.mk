################################################################################
# Cryptography Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

cryptography_dist_url  := https://files.pythonhosted.org/packages/12/e3/c46c274cf466b24e5d44df5d5cd31a31ff23e57f074a2bb30931a8c9b01a/cryptography-39.0.0.tar.gz
cryptography_dist_sum  := bac0268ca0b6a12adc2d2a1f4ec047aad0643afa021d43574f189187a6a6802bc79e9329afd77a950b158040c85137da4cdee1973f4bb89815ad2203fa969393
cryptography_dist_name := $(notdir $(cryptography_dist_url))
cryptography_vers      := $(patsubst cryptography-%.tar.gz,%,$(cryptography_dist_name))
cryptography_brief     := Python_ library exposing cryptographic recipes and primitives
cryptography_home      := https://github.com/pyca/cryptography

define cryptography_desc
The cryptography library is designed to be a "one-stop-shop" for all your
cryptographic needs in Python_.

As an alternative to the libraries that came before it, cryptography tries to
address some of the issues with those libraries:

* lack of PyPy and Python 3 support ;
* lack of maintenance ;
* use of poor implementations of algorithms (i.e. ones with known side-channel
  attacks) ;
* lack of high level, "Cryptography for humans", APIs ;
* absence of algorithms such as AES-GCM ;
* poor introspectability, and thus poor testability ;
* extremely error prone APIs, and bad defaults.
endef

define fetch_cryptography_dist
$(call download_csum,$(cryptography_dist_url),\
                     $(FETCHDIR)/$(cryptography_dist_name),\
                     $(cryptography_dist_sum))
endef
$(call gen_fetch_rules,cryptography,\
                       cryptography_dist_name,\
                       fetch_cryptography_dist)

define xtract_cryptography
$(call rmrf,$(srcdir)/cryptography)
$(call untar,$(srcdir)/cryptography,\
             $(FETCHDIR)/$(cryptography_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cryptography,xtract_cryptography)

$(call gen_dir_rules,cryptography)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cryptography,\
                stage-setuptools-rust stage-cffi stage-openssl)

$(call gen_python_module_rules,stage-cryptography,cryptography,$(stagedir))
