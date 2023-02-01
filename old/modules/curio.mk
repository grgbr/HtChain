curio_dist_url  := https://files.pythonhosted.org/packages/e9/d9/ed3d361fea04f3300eb69a23d97aa1be003c9dab0e5b10244fef0ad2c1ba/curio-1.6.tar.gz
curio_dist_sum  := 562a586db20216ba7d2be8263deb9eb079e56048f9b8906d11d5f45aa81c5247
curio_dist_name := $(notdir $(curio_dist_url))

define fetch_curio_dist
$(call _download,$(curio_dist_url),$(FETCHDIR)/$(curio_dist_name).tmp)
cat $(FETCHDIR)/$(curio_dist_name).tmp | \
	sha256sum --check --status <(echo "$(curio_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(curio_dist_name).tmp,\
          $(FETCHDIR)/$(curio_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(curio_dist_name)'
endef

# As fetch_curio_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(curio_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,curio,curio_dist_name,fetch_curio_dist)

define xtract_curio
$(call rmrf,$(srcdir)/curio)
$(call untar,$(srcdir)/curio,\
             $(FETCHDIR)/$(curio_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,curio,xtract_curio)

$(call gen_dir_rules,curio)

# $(1): targets base name / module name
define curio_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    SSL_CERT_DIR=/etc/ssl/certs \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-curio,stage-python)
$(call gen_check_deps,stage-curio,stage-pytest stage-openssl)

check_stage-curio = $(call curio_check_cmds,stage-curio)
$(call gen_python_module_rules,stage-curio,curio,\
                                           $(stagedir),\
                                           ,\
                                           check_stage-curio)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-curio,stage-python)
$(call gen_check_deps,final-curio,stage-pytest stage-openssl)

check_final-curio = $(call curio_check_cmds,final-curio)
$(call gen_python_module_rules,final-curio,curio,\
                                           $(PREFIX),\
                                           $(finaldir),\
                                           check_final-curio)
