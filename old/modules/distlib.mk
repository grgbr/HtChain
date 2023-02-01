distlib_dist_url  := https://files.pythonhosted.org/packages/58/07/815476ae605bcc5f95c87a62b95e74a1bce0878bc7a3119bc2bf4178f175/distlib-0.3.6.tar.gz
distlib_dist_sum  := 14bad2d9b04d3a36127ac97f30b12a19268f211063d8f8ee4f47108896e11b46
distlib_dist_name := $(notdir $(distlib_dist_url))

define fetch_distlib_dist
$(call _download,$(distlib_dist_url),$(FETCHDIR)/$(distlib_dist_name).tmp)
cat $(FETCHDIR)/$(distlib_dist_name).tmp | \
	sha256sum --check --status <(echo "$(distlib_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(distlib_dist_name).tmp,\
          $(FETCHDIR)/$(distlib_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(distlib_dist_name)'
endef

# As fetch_distlib_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(distlib_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,distlib,distlib_dist_name,fetch_distlib_dist)

define xtract_distlib
$(call rmrf,$(srcdir)/distlib)
$(call untar,$(srcdir)/distlib,\
             $(FETCHDIR)/$(distlib_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,distlib,xtract_distlib)

$(call gen_dir_rules,distlib)

# $(1): targets base name / module name
#
# Setup HOME directory so that test suite uses .pypirc init file located into
# build directory.
# Also instruct OpenSSL to search for system-wide certificates installed into
# /etc/ssl/certs by the ca-certificates package (using update-ca-certificates
# command)
define distlib_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    HOME="$(builddir)/$(strip $(1))" \
    SSL_CERT_DIR=/etc/ssl/certs \
$(stagedir)/bin/pytest -k 'not test_sequencer_basic'
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-distlib,stage-wheel)
$(call gen_check_deps,stage-distlib,stage-pytest stage-openssl)

check_stage-distlib = $(call distlib_check_cmds,stage-distlib)
$(call gen_python_module_rules,stage-distlib,distlib,\
                                             $(stagedir),\
                                             ,\
                                             check_stage-distlib)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-distlib,stage-wheel)
$(call gen_check_deps,final-distlib,stage-pytest stage-openssl)

check_final-distlib = $(call distlib_check_cmds,final-distlib)
$(call gen_python_module_rules,final-distlib,distlib,\
                                             $(PREFIX),\
                                             $(finaldir),\
                                             check_final-distlib)
