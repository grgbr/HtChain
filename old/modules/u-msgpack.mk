u-msgpack_dist_url  := https://files.pythonhosted.org/packages/44/a7/1cb4f059bbf72ea24364f9ba3ef682725af09969e29df988aa5437f0044e/u-msgpack-python-2.7.2.tar.gz
u-msgpack_dist_sum  := e86f7ac6aa0ef4c6c49f004b4fd435bce99c23e2dd5d73003f3f9816024c2bd8
u-msgpack_dist_name := $(notdir $(u-msgpack_dist_url))

define fetch_u-msgpack_dist
$(call _download,$(u-msgpack_dist_url),$(FETCHDIR)/$(u-msgpack_dist_name).tmp)
cat $(FETCHDIR)/$(u-msgpack_dist_name).tmp | \
	sha256sum --check --status <(echo "$(u-msgpack_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(u-msgpack_dist_name).tmp,\
          $(FETCHDIR)/$(u-msgpack_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(u-msgpack_dist_name)'
endef

# As fetch_u-msgpack_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(u-msgpack_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,u-msgpack,u-msgpack_dist_name,fetch_u-msgpack_dist)

define xtract_u-msgpack
$(call rmrf,$(srcdir)/u-msgpack)
$(call untar,$(srcdir)/u-msgpack,\
             $(FETCHDIR)/$(u-msgpack_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,u-msgpack,xtract_u-msgpack)

$(call gen_dir_rules,u-msgpack)

# $(1): targets base name / module name
define u-msgpack_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-u-msgpack,stage-python-msgpack)
$(call gen_check_deps,stage-u-msgpack,stage-pytest)

check_stage-u-msgpack = $(call u-msgpack_check_cmds,stage-u-msgpack)
$(call gen_python_module_rules,stage-u-msgpack,\
                               u-msgpack,\
                               $(stagedir),\
                               ,\
                               check_stage-u-msgpack)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-u-msgpack,stage-python-msgpack)
$(call gen_check_deps,final-u-msgpack,stage-pytest)

check_final-u-msgpack = $(call u-msgpack_check_cmds,final-u-msgpack)
$(call gen_python_module_rules,final-u-msgpack,\
                               u-msgpack,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-u-msgpack)
