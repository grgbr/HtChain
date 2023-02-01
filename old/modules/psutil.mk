psutil_dist_url  := https://files.pythonhosted.org/packages/3d/7d/d05864a69e452f003c0d77e728e155a89a2a26b09e64860ddd70ad64fb26/psutil-5.9.4.tar.gz
psutil_dist_sum  := 3d7f9739eb435d4b1338944abe23f49584bde5395f27487d2ee25ad9a8774a62
psutil_dist_name := $(notdir $(psutil_dist_url))

define fetch_psutil_dist
$(call _download,$(psutil_dist_url),$(FETCHDIR)/$(psutil_dist_name).tmp)
cat $(FETCHDIR)/$(psutil_dist_name).tmp | \
	sha256sum --check --status <(echo "$(psutil_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(psutil_dist_name).tmp,\
          $(FETCHDIR)/$(psutil_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(psutil_dist_name)'
endef

# As fetch_psutil_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(psutil_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,psutil,psutil_dist_name,fetch_psutil_dist)

define xtract_psutil
$(call rmrf,$(srcdir)/psutil)
$(call untar,$(srcdir)/psutil,\
             $(FETCHDIR)/$(psutil_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,psutil,xtract_psutil)

$(call gen_dir_rules,psutil)

# $(1): targets base name / module name
define psutil_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    PYTHONWARNINGS=all \
    PSUTIL_TESTING=1 \
    PSUTIL_DEBUG=1 \
$(stage_python) psutil/tests/runner.py
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-psutil,stage-wheel)
$(call gen_check_deps,stage-psutil,stage-pytest stage-psutil)

check_stage-psutil = $(call psutil_check_cmds,stage-psutil)
$(call gen_python_module_rules,stage-psutil,\
                               psutil,\
                               $(stagedir),\
                               ,\
                               check_stage-psutil)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-psutil,stage-wheel)
$(call gen_check_deps,final-psutil,stage-pytest stage-psutil)

check_final-psutil = $(call psutil_check_cmds,final-psutil)
$(call gen_python_module_rules,final-psutil,\
                               psutil,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-psutil)
