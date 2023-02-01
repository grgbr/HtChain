# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

httpbin_dist_url  := https://files.pythonhosted.org/packages/01/9b/9e208e6ff598adac7cc63031d0c7191f2733280bcc37607e8d8a82960d2e/httpbin-0.7.0.tar.gz
httpbin_dist_sum  := cbb37790c91575f4f15757f42ad41d9f729eb227d5edbe89e4ec175486db8dfa
httpbin_dist_name := $(notdir $(httpbin_dist_url))

define fetch_httpbin_dist
$(call _download,$(httpbin_dist_url),$(FETCHDIR)/$(httpbin_dist_name).tmp)
cat $(FETCHDIR)/$(httpbin_dist_name).tmp | \
	sha256sum --check --status <(echo "$(httpbin_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(httpbin_dist_name).tmp,\
          $(FETCHDIR)/$(httpbin_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(httpbin_dist_name)'
endef

# As fetch_httpbin_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(httpbin_dist_name): SHELL:=/bin/bash
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
