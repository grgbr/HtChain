covdefaults_dist_url  := https://files.pythonhosted.org/packages/9b/24/36a45f0734a1553ccbbd92683af7369bc919dce219ff42f921323d0be7db/covdefaults-2.2.2.tar.gz
covdefaults_dist_sum  := e543862ee0347769b47b27fa586d690e6b91587a3dcaaf8552fcfb1fac03d061
covdefaults_dist_name := $(notdir $(covdefaults_dist_url))

define fetch_covdefaults_dist
$(call _download,$(covdefaults_dist_url),$(FETCHDIR)/$(covdefaults_dist_name).tmp)
cat $(FETCHDIR)/$(covdefaults_dist_name).tmp | \
	sha256sum --check --status <(echo "$(covdefaults_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(covdefaults_dist_name).tmp,\
          $(FETCHDIR)/$(covdefaults_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(covdefaults_dist_name)'
endef

# As fetch_covdefaults_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(covdefaults_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,covdefaults,covdefaults_dist_name,fetch_covdefaults_dist)

define xtract_covdefaults
$(call rmrf,$(srcdir)/covdefaults)
$(call untar,$(srcdir)/covdefaults,\
             $(FETCHDIR)/$(covdefaults_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,covdefaults,xtract_covdefaults)

$(call gen_dir_rules,covdefaults)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-covdefaults,stage-coverage)

$(call gen_python_module_rules,stage-covdefaults,covdefaults,$(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-covdefaults,stage-coverage)

$(call gen_python_module_rules,final-covdefaults,covdefaults,\
                                                 $(PREFIX),\
                                                 $(finaldir))
