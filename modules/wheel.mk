# Required to build some python modules from source.

wheel_dist_url  := https://files.pythonhosted.org/packages/a2/b8/6a06ff0f13a00fc3c3e7d222a995526cbca26c1ad107691b6b1badbbabf1/wheel-0.38.4.tar.gz
wheel_dist_sum  := 965f5259b566725405b05e7cf774052044b1ed30119b5d586b2703aafe8719ac
wheel_dist_name := $(notdir $(wheel_dist_url))

define fetch_wheel_dist
$(call _download,$(wheel_dist_url),$(FETCHDIR)/$(wheel_dist_name).tmp)
cat $(FETCHDIR)/$(wheel_dist_name).tmp | \
	sha256sum --check --status <(echo "$(wheel_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(wheel_dist_name).tmp,\
          $(FETCHDIR)/$(wheel_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(wheel_dist_name)'
endef

# As fetch_wheel_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(wheel_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,wheel,wheel_dist_name,fetch_wheel_dist)

define xtract_wheel
$(call rmrf,$(srcdir)/wheel)
$(call untar,$(srcdir)/wheel,\
             $(FETCHDIR)/$(wheel_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,wheel,xtract_wheel)

$(call gen_dir_rules,wheel)

# $(1): targets base name / module name
#
# Disable MacOS related tests
define wheel_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose --deselect tests/test_macosx_libfile.py
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-wheel,stage-python)
$(call gen_check_deps,stage-wheel,stage-pytest)

check_stage-wheel = $(call wheel_check_cmds,stage-wheel)
$(call gen_python_module_rules,stage-wheel,\
                               wheel,\
                               $(stagedir),\
                               ,\
                               check_stage-wheel)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-wheel,stage-python)
$(call gen_check_deps,final-wheel,stage-pytest)

check_final-wheel = $(call wheel_check_cmds,final-wheel)
$(call gen_python_module_rules,final-wheel,\
                               wheel,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-wheel)
