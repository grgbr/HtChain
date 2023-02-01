certifi_dist_url  := https://files.pythonhosted.org/packages/37/f7/2b1b0ec44fdc30a3d31dfebe52226be9ddc40cd6c0f34ffc8923ba423b69/certifi-2022.12.7.tar.gz
certifi_dist_sum  := 35824b4c3a97115964b408844d64aa14db1cc518f6562e8d7261699d1350a9e3
certifi_dist_name := $(notdir $(certifi_dist_url))

define fetch_certifi_dist
$(call _download,$(certifi_dist_url),$(FETCHDIR)/$(certifi_dist_name).tmp)
cat $(FETCHDIR)/$(certifi_dist_name).tmp | \
	sha256sum --check --status <(echo "$(certifi_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(certifi_dist_name).tmp,\
          $(FETCHDIR)/$(certifi_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(certifi_dist_name)'
endef

# As fetch_certifi_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(certifi_dist_name): SHELL:=/bin/bash
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
