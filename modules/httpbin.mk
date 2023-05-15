################################################################################
# httpbin Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

httpbin_dist_url  := https://files.pythonhosted.org/packages/01/9b/9e208e6ff598adac7cc63031d0c7191f2733280bcc37607e8d8a82960d2e/httpbin-0.7.0.tar.gz
httpbin_dist_sum  := 82e80058b58943637e9f8191764cea79bf7a6e40f36069f9b5d3f908585dbef20a03ef070d1f865d350920b6e874a93a48a544b05c14ff4911038ec2c20f6f63
httpbin_dist_name := $(notdir $(httpbin_dist_url))
httpbin_vers      := $(patsubst httpbin-%.tar.gz,%,$(httpbin_dist_name))
httpbin_brief     := Python_ HTTP request and response service
httpbin_home      := https://github.com/requests/httpbin

define httpbin_desc
httpbin is a test server for testing HTTP libraries and apps. It features
several endpoints to cover a multitude of HTTP scenarios.  httpbin ships as a
Python_ library and could be run directly by the Python_ interpreter, or as a
WSGI app e.g. with Gunicorn. The endpoint responses are JSON-encoded.
endef

define fetch_httpbin_dist
$(call download_csum,$(httpbin_dist_url),\
                     $(httpbin_dist_name),\
                     $(httpbin_dist_sum))
endef
$(call gen_fetch_rules,httpbin,httpbin_dist_name,fetch_httpbin_dist)

define xtract_httpbin
$(call rmrf,$(srcdir)/httpbin)
$(call untar,$(srcdir)/httpbin,\
             $(FETCHDIR)/$(httpbin_dist_name),\
             --strip-components=1)
cd $(srcdir)/httpbin && \
patch -p1 < $(PATCHDIR)/httpbin-0.7.0-000-fix_werkzeux_2_2_deprecation.patch
endef
$(call gen_xtract_rules,httpbin,xtract_httpbin)

$(call gen_dir_rules,httpbin)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-httpbin,stage-brotlipy \
                              stage-decorator \
                              stage-flask \
                              stage-itsdangerous \
                              stage-markupsafe \
                              stage-raven \
                              stage-six \
                              stage-werkzeug)

$(call gen_python_module_rules,stage-httpbin,\
                               httpbin,\
                               $(stagedir))
