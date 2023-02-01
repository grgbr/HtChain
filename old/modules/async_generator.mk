async_generator_dist_url  := https://files.pythonhosted.org/packages/ce/b6/6fa6b3b598a03cba5e80f829e0dadbb49d7645f523d209b2fb7ea0bbb02a/async_generator-1.10.tar.gz
async_generator_dist_sum  := 6ebb3d106c12920aaae42ccb6f787ef5eefdcdd166ea3d628fa8476abe712144
async_generator_dist_name := $(notdir $(async_generator_dist_url))

define fetch_async_generator_dist
$(call _download,$(async_generator_dist_url),$(FETCHDIR)/$(async_generator_dist_name).tmp)
cat $(FETCHDIR)/$(async_generator_dist_name).tmp | \
	sha256sum --check --status <(echo "$(async_generator_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(async_generator_dist_name).tmp,\
          $(FETCHDIR)/$(async_generator_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(async_generator_dist_name)'
endef

# As fetch_async_generator_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(async_generator_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,async_generator,async_generator_dist_name,fetch_async_generator_dist)

define xtract_async_generator
$(call rmrf,$(srcdir)/async_generator)
$(call untar,$(srcdir)/async_generator,\
             $(FETCHDIR)/$(async_generator_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,async_generator,xtract_async_generator)

$(call gen_dir_rules,async_generator)

# $(1): targets base name / module name
define async_generator_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-async_generator,stage-python)
$(call gen_check_deps,stage-async_generator,stage-pytest)

check_stage-async_generator = $(call async_generator_check_cmds,\
                                     stage-async_generator)
$(call gen_python_module_rules,stage-async_generator,\
                               async_generator,\
                               $(stagedir),\
                               ,\
                               check_stage-async_generator)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-async_generator,stage-python)
$(call gen_check_deps,final-async_generator,stage-pytest)

check_final-async_generator = $(call async_generator_check_cmds,\
                                     final-async_generator)
$(call gen_python_module_rules,final-async_generator,\
                               async_generator,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-async_generator)
