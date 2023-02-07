# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

urllib3_dist_url  := https://files.pythonhosted.org/packages/c5/52/fe421fb7364aa738b3506a2d99e4f3a56e079c0a798e9f4fa5e14c60922f/urllib3-1.26.14.tar.gz
urllib3_dist_sum  := 076907bf8fd355cde77728471316625a4d2f7e713c125f51953bb5b3eecf4f72
urllib3_dist_name := $(notdir $(urllib3_dist_url))

define fetch_urllib3_dist
$(call _download,$(urllib3_dist_url),$(FETCHDIR)/$(urllib3_dist_name).tmp)
cat $(FETCHDIR)/$(urllib3_dist_name).tmp | \
	sha256sum --check --status <(echo "$(urllib3_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(urllib3_dist_name).tmp,\
          $(FETCHDIR)/$(urllib3_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(urllib3_dist_name)'
endef

# As fetch_urllib3_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(urllib3_dist_name): SHELL:=/bin/bash
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

check_stage-urllib3 = $(call urllib3_check_cmds,stage-urllib3)
$(call gen_python_module_rules,stage-urllib3,\
                               urllib3,\
                               $(stagedir),\
                               ,\
                               check_stage-urllib3)

################################################################################
# Final definitions
################################################################################

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

check_final-urllib3 = $(call urllib3_check_cmds,final-urllib3)
$(call gen_python_module_rules,final-urllib3,\
                               urllib3,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-urllib3)
