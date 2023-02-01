pytest-asyncio_dist_url  := https://files.pythonhosted.org/packages/6e/06/38b0ca5d53582bb49697626975b5540435ea064762d852b5c66646c729e9/pytest-asyncio-0.20.3.tar.gz
pytest-asyncio_dist_sum  := 83cbf01169ce3e8eb71c6c278ccb0574d1a7a3bb8eaaf5e50e0ad342afb33b36
pytest-asyncio_dist_name := $(notdir $(pytest-asyncio_dist_url))

define fetch_pytest-asyncio_dist
$(call _download,$(pytest-asyncio_dist_url),$(FETCHDIR)/$(pytest-asyncio_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-asyncio_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-asyncio_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-asyncio_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-asyncio_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-asyncio_dist_name)'
endef

# As fetch_pytest-asyncio_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-asyncio_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-asyncio,pytest-asyncio_dist_name,fetch_pytest-asyncio_dist)

define xtract_pytest-asyncio
$(call rmrf,$(srcdir)/pytest-asyncio)
$(call untar,$(srcdir)/pytest-asyncio,\
             $(FETCHDIR)/$(pytest-asyncio_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-asyncio,xtract_pytest-asyncio)

$(call gen_dir_rules,pytest-asyncio)

# $(1): targets base name / module name
#
# Skip trio test suite since not mandatory for runtime and pytest-trio depends
# on trio which depends on cryptography which requires a full Rust ecosystem...
# We don't want Rust for now !
define pytest-asyncio_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -k 'not test_strict_mode_ignores_trio_fixtures'
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-asyncio,stage-pytest \
                                     stage-wheel \
                                     stage-setuptools-scm)
$(call gen_check_deps,stage-pytest-asyncio,stage-coverage \
                                           stage-hypothesis \
                                           stage-flaky)

check_stage-pytest-asyncio = $(call pytest-asyncio_check_cmds,\
                                    stage-pytest-asyncio)
$(call gen_python_module_rules,stage-pytest-asyncio,pytest-asyncio,\
                                                    $(stagedir),\
                                                    ,\
                                                    check_stage-pytest-asyncio)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytest-asyncio,stage-pytest \
                                     stage-wheel \
                                     stage-setuptools-scm)
$(call gen_check_deps,final-pytest-asyncio,stage-coverage \
                                           stage-hypothesis \
                                           stage-flaky)

check_final-pytest-asyncio = $(call pytest-asyncio_check_cmds,\
                                    final-pytest-asyncio)
$(call gen_python_module_rules,final-pytest-asyncio,pytest-asyncio,\
                                                    $(PREFIX),\
                                                    $(finaldir),\
                                                    check_final-pytest-asyncio)
