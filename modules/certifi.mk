################################################################################
# certifi modules
################################################################################

certifi_dist_url  := https://files.pythonhosted.org/packages/37/f7/2b1b0ec44fdc30a3d31dfebe52226be9ddc40cd6c0f34ffc8923ba423b69/certifi-2022.12.7.tar.gz
certifi_dist_sum  := fd08b6bf138aa1b0a47909077642713d80f036e4b18de2c7f236a185521db3d6498a81a60b150124cc4bc21dd7e687badad4324a898117060c9e4ec93dfbdbe8
certifi_dist_name := $(notdir $(certifi_dist_url))
certifi_vers      := $(patsubst certifi-%.tar.gz,%,$(certifi_dist_name))
certifi_brief     := Root certificates for Python_ verification of SSL certs and TLS hosts
certifi_home      := https://github.com/certifi/python-certifi

define certifi_desc
Certifi is a carefully curated collection of Root Certificates for validating
the trustworthiness of SSL certificates while verifying the identity of TLS
hosts. It has been extracted from the Requests_ project.
endef

define fetch_certifi_dist
$(call download_csum,$(certifi_dist_url),\
                     $(FETCHDIR)/$(certifi_dist_name),\
                     $(certifi_dist_sum))
endef
$(call gen_fetch_rules,certifi,certifi_dist_name,fetch_certifi_dist)

define xtract_certifi
$(call rmrf,$(srcdir)/certifi)
$(call untar,$(srcdir)/certifi,\
             $(FETCHDIR)/$(certifi_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,certifi,xtract_certifi)

$(call gen_dir_rules,certifi)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-certifi,stage-python)

$(call gen_python_module_rules,stage-certifi,\
                               certifi,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-certifi,stage-python)

$(call gen_python_module_rules,final-certifi,\
                               certifi,\
                               $(PREFIX),\
                               $(finaldir))
