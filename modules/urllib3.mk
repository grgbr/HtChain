################################################################################
# urllib3 Python modules
################################################################################

urllib3_dist_url  := https://files.pythonhosted.org/packages/c5/52/fe421fb7364aa738b3506a2d99e4f3a56e079c0a798e9f4fa5e14c60922f/urllib3-1.26.14.tar.gz
urllib3_dist_sum  := 0a2dffcb4d3b199e1d82c2bb0d8f4e6b57466bdc43e31dbed62b392ef32e021f6d31cb53ebedef9e1a62b1113f7a370e9f0baa36e3fba942a2543473e4df0828
urllib3_dist_name := $(notdir $(urllib3_dist_url))
urllib3_vers      := $(patsubst urllib3-%.tar.gz,%,$(urllib3_dist_name))
urllib3_brief     := HTTP library with thread-safe connection pooling for Python_
urllib3_home      := https://urllib3.readthedocs.io/

define urllib3_desc
urllib3 supports features left out of urllib and urllib2 libraries.

* re-use the same socket connection for multiple requests
  (``HTTPConnectionPool`` and ``HTTPSConnectionPool``) with optional client-side
  certificate verification;
* file posting (``encode_multipart_formdata``);
* built-in redirection and retries (optional);
* supports gzip and deflate decoding;
* thread-safe and sanity-safe;
* small and easy to understand codebase perfect for extending and building upon.
endef

define fetch_urllib3_dist
$(call download_csum,$(urllib3_dist_url),\
                     $(FETCHDIR)/$(urllib3_dist_name),\
                     $(urllib3_dist_sum))
endef
$(call gen_fetch_rules,urllib3,urllib3_dist_name,fetch_urllib3_dist)

define xtract_urllib3
$(call rmrf,$(srcdir)/urllib3)
$(call untar,$(srcdir)/urllib3,\
             $(FETCHDIR)/$(urllib3_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,urllib3,xtract_urllib3)

$(call gen_dir_rules,urllib3)

# $(1): targets base name / module name
define urllib3_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    SSL_CERT_DIR="/etc/ssl/certs" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-urllib3 = $(call urllib3_check_cmds,stage-urllib3)

$(call gen_deps,stage-urllib3,stage-wheel)
$(call gen_check_deps,stage-urllib3,\
                      stage-urllib3 \
                      stage-pytest \
                      stage-pytest-timeout \
                      stage-pytest-freezegun \
                      stage-trustme \
                      stage-tornado \
                      stage-python-dateutil \
                      stage-flaky \
                      stage-pysocks \
                      stage-mock)
$(call gen_python_module_rules,stage-urllib3,urllib3,$(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-urllib3 = $(call urllib3_check_cmds,final-urllib3)

$(call gen_deps,final-urllib3,stage-wheel)
$(call gen_check_deps,final-urllib3,\
                      stage-urllib3 \
                      stage-pytest \
                      stage-pytest-timeout \
                      stage-pytest-freezegun \
                      stage-trustme \
                      stage-tornado \
                      stage-python-dateutil \
                      stage-flaky \
                      stage-pysocks \
                      stage-mock)
$(call gen_python_module_rules,final-urllib3,urllib3,$(PREFIX),$(finaldir))
