pytest-xprocess_dist_url  := https://files.pythonhosted.org/packages/52/43/e9149203fdb89a513aa87091e49ab7fb8412f85cccf741b413474bd603bf/pytest-xprocess-0.22.2.tar.gz
pytest-xprocess_dist_sum  := 599ee25b938e8f259e18d9c5b4d6384884f8a6a28ca51eed32d0d9526bdcf77c
pytest-xprocess_dist_name := $(notdir $(pytest-xprocess_dist_url))

define fetch_pytest-xprocess_dist
$(call _download,$(pytest-xprocess_dist_url),$(FETCHDIR)/$(pytest-xprocess_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-xprocess_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-xprocess_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-xprocess_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-xprocess_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-xprocess_dist_name)'
endef

# As fetch_pytest-xprocess_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-xprocess_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-xprocess,pytest-xprocess_dist_name,fetch_pytest-xprocess_dist)

define xtract_pytest-xprocess
$(call rmrf,$(srcdir)/pytest-xprocess)
$(call untar,$(srcdir)/pytest-xprocess,\
             $(FETCHDIR)/$(pytest-xprocess_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-xprocess,xtract_pytest-xprocess)

$(call gen_dir_rules,pytest-xprocess)

# $(1): targets base name / module name
define pytest-xprocess_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-xprocess,stage-pytest stage-psutil)

check_stage-pytest-xprocess = $(call pytest-xprocess_check_cmds,\
                                     stage-pytest-xprocess)
$(call gen_python_module_rules,stage-pytest-xprocess,\
                               pytest-xprocess,\
                               $(stagedir),\
                               ,\
                               check_stage-pytest-xprocess)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytest-xprocess,stage-pytest stage-psutil)

check_final-pytest-xprocess = $(call pytest-xprocess_check_cmds,\
                                     final-pytest-xprocess)
$(call gen_python_module_rules,final-pytest-xprocess,\
                               pytest-xprocess,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pytest-xprocess)
