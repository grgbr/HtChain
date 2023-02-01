requests_dist_url  := https://files.pythonhosted.org/packages/9d/ee/391076f5937f0a8cdf5e53b701ffc91753e87b07d66bae4a09aa671897bf/requests-2.28.2.tar.gz
requests_dist_sum  := 98b1b2782e3c6c4904938b84c0eb932721069dfdb9134313beff7c83c2df24bf
requests_dist_name := $(notdir $(requests_dist_url))

define fetch_requests_dist
$(call _download,$(requests_dist_url),$(FETCHDIR)/$(requests_dist_name).tmp)
cat $(FETCHDIR)/$(requests_dist_name).tmp | \
	sha256sum --check --status <(echo "$(requests_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(requests_dist_name).tmp,\
          $(FETCHDIR)/$(requests_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(requests_dist_name)'
endef

# As fetch_requests_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(requests_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,requests,requests_dist_name,fetch_requests_dist)

define xtract_requests
$(call rmrf,$(srcdir)/requests)
$(call untar,$(srcdir)/requests,\
             $(FETCHDIR)/$(requests_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,requests,xtract_requests)

$(call gen_dir_rules,requests)

# $(1): targets base name / module name
#
# Note: disable test_https_warnings:
# see issue https://github.com/psf/requests/issues/5530
define requests_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose -k "not test_https_warnings"
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-requests,stage-urllib3 \
                               stage-idna \
                               stage-certifi \
                               stage-charset-normalizer)
$(call gen_check_deps,stage-requests,stage-pytest-cov \
                                     stage-pytest-xdist \
                                     stage-pytest-httpbin \
                                     stage-pytest-mock \
                                     stage-pysocks)

check_stage-requests = $(call requests_check_cmds,stage-requests)
$(call gen_python_module_rules,stage-requests,\
                               requests,\
                               $(stagedir),\
                               ,\
                               check_stage-requests)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-requests,stage-urllib3 \
                               stage-idna \
                               stage-certifi \
                               stage-charset-normalizer)
$(call gen_check_deps,final-requests,stage-pytest-cov \
                                     stage-pytest-xdist \
                                     stage-pytest-httpbin \
                                     stage-pytest-mock \
                                     stage-pysocks)

check_final-requests = $(call requests_check_cmds,final-requests)
$(call gen_python_module_rules,final-requests,\
                               requests,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-requests)
