# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

setuptools-scm_dist_url  := https://files.pythonhosted.org/packages/98/12/2c1e579bb968759fc512391473340d0661b1a8c96a59fb7c65b02eec1321/setuptools_scm-7.1.0.tar.gz
setuptools-scm_dist_sum  := 6c508345a771aad7d56ebff0e70628bf2b0ec7573762be9960214730de278f27
setuptools-scm_dist_name := $(notdir $(setuptools-scm_dist_url))

define fetch_setuptools-scm_dist
$(call _download,$(setuptools-scm_dist_url),\
                 $(FETCHDIR)/$(setuptools-scm_dist_name).tmp)
cat $(FETCHDIR)/$(setuptools-scm_dist_name).tmp | \
	sha256sum --check --status <(echo "$(setuptools-scm_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(setuptools-scm_dist_name).tmp,\
          $(FETCHDIR)/$(setuptools-scm_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(setuptools-scm_dist_name)'
endef

# As fetch_setuptools-scm_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(setuptools-scm_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,setuptools-scm,\
                       setuptools-scm_dist_name,\
                       fetch_setuptools-scm_dist)

define xtract_setuptools-scm
$(call rmrf,$(srcdir)/setuptools-scm)
$(call untar,$(srcdir)/setuptools-scm,\
             $(FETCHDIR)/$(setuptools-scm_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,setuptools-scm,xtract_setuptools-scm)

$(call gen_dir_rules,setuptools-scm)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-setuptools-scm,stage-wheel \
                                     stage-packaging \
                                     stage-tomli \
                                     stage-typing-extensions)

$(call gen_python_module_rules,stage-setuptools-scm,setuptools-scm,$(stagedir))
