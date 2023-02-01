# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

cryptography_dist_url  := https://files.pythonhosted.org/packages/12/e3/c46c274cf466b24e5d44df5d5cd31a31ff23e57f074a2bb30931a8c9b01a/cryptography-39.0.0.tar.gz
cryptography_dist_sum  := f964c7dcf7802d133e8dbd1565914fa0194f9d683d82411989889ecd701e8adf
cryptography_dist_name := $(notdir $(cryptography_dist_url))

define fetch_cryptography_dist
$(call _download,$(cryptography_dist_url),\
                 $(FETCHDIR)/$(cryptography_dist_name).tmp)
cat $(FETCHDIR)/$(cryptography_dist_name).tmp | \
	sha256sum --check --status <(echo "$(cryptography_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(cryptography_dist_name).tmp,\
          $(FETCHDIR)/$(cryptography_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(cryptography_dist_name)'
endef

# As fetch_cryptography_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(cryptography_dist_name): SHELL:=/bin/bash
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
