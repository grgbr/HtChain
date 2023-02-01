chardet_dist_url  := https://files.pythonhosted.org/packages/41/32/cdc91dcf83849c7385bf8e2a5693d87376536ed000807fa07f5eab33430d/chardet-5.1.0.tar.gz
chardet_dist_sum  := 0d62712b956bc154f85fb0a266e2a3c5913c2967e00348701b32411d6def31e5
chardet_dist_name := $(notdir $(chardet_dist_url))

define fetch_chardet_dist
$(call _download,$(chardet_dist_url),$(FETCHDIR)/$(chardet_dist_name).tmp)
cat $(FETCHDIR)/$(chardet_dist_name).tmp | \
	sha256sum --check --status <(echo "$(chardet_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(chardet_dist_name).tmp,\
          $(FETCHDIR)/$(chardet_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(chardet_dist_name)'
endef

# As fetch_chardet_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(chardet_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,chardet,chardet_dist_name,fetch_chardet_dist)

define xtract_chardet
$(call rmrf,$(srcdir)/chardet)
$(call untar,$(srcdir)/chardet,\
             $(FETCHDIR)/$(chardet_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,chardet,xtract_chardet)

$(call gen_dir_rules,chardet)

# $(1): targets base name / module name
#
# Skip test_detect_all_and_detect_one_should_agree test case since failing : see
# https://github.com/chardet/chardet/issues/256
define chardet_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -k 'not test_detect_all_and_detect_one_should_agree'
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-chardet,stage-python)
$(call gen_check_deps,stage-chardet,stage-pytest)

check_stage-chardet = $(call chardet_check_cmds,stage-chardet)
$(call gen_python_module_rules,stage-chardet,chardet,\
                                             $(stagedir),\
                                             ,\
                                             check_stage-chardet)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-chardet,stage-python)
$(call gen_check_deps,final-chardet,stage-pytest)

check_final-chardet = $(call chardet_check_cmds,final-chardet)
$(call gen_python_module_rules,final-chardet,chardet,\
                                             $(PREFIX),\
                                             $(finaldir),\
                                             check_final-chardet)
