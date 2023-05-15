################################################################################
# requests Python modules
################################################################################

requests_dist_url  := https://files.pythonhosted.org/packages/9d/ee/391076f5937f0a8cdf5e53b701ffc91753e87b07d66bae4a09aa671897bf/requests-2.28.2.tar.gz
requests_dist_sum  := 3c4ba19a2bb6ba38a4118cf246db3855401869d54ee7ebd9bee40b435420381fb737d4c69768f2bd97914a30d66233c7058cec51aa629af0dff3b04e6f997a3d
requests_dist_name := $(notdir $(requests_dist_url))
requests_vers      := $(patsubst requests-%.tar.gz,%,$(requests_dist_name))
requests_brief     := Elegant and simple HTTP library for Python_
requests_home      := https://requests.readthedocs.io/

define requests_desc
Requests allow you to send HTTP/1.1 requests. You can add headers, form data,
multipart files, and parameters with simple Python_ dictionaries, and access the
response data in the same way. It\'s powered by httplib and urllib3_, but it
does all the hard work and crazy hacks for you.

Features:

* International Domains and URLs
* Keep-Alive & Connection Pooling
* Sessions with Cookie Persistence
* Browser-style SSL Verification
* Basic/Digest Authentication
* Elegant Key/Value Cookies
* Automatic Decompression
* Unicode Response Bodies
* Multipart File Uploads
* Connection Timeouts
endef

define fetch_requests_dist
$(call download_csum,$(requests_dist_url),\
                     $(requests_dist_name),\
                     $(requests_dist_sum))
endef
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
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose --full-trace -vv -k "not test_https_warnings"
endef

################################################################################
# Staging definitions
################################################################################

check_stage-requests = $(call requests_check_cmds,stage-requests)

$(call gen_deps,stage-requests,stage-urllib3 \
                               stage-idna \
                               stage-certifi \
                               stage-charset-normalizer)
$(call gen_check_deps,stage-requests,stage-pytest-cov \
                                     stage-pytest-xdist \
                                     stage-pytest-httpbin \
                                     stage-pytest-mock \
                                     stage-pysocks)
$(call gen_python_module_rules,stage-requests,requests,$(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-requests = $(call requests_check_cmds,final-requests)

$(call gen_deps,final-requests,stage-urllib3 \
                               stage-idna \
                               stage-certifi \
                               stage-charset-normalizer)
$(call gen_check_deps,final-requests,stage-pytest-cov \
                                     stage-pytest-xdist \
                                     stage-pytest-httpbin \
                                     stage-pytest-mock \
                                     stage-pysocks)
$(call gen_python_module_rules,final-requests,requests,$(PREFIX),$(finaldir))
