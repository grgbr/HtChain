python-msgpack_dist_url  := https://files.pythonhosted.org/packages/22/44/0829b19ac243211d1d2bd759999aa92196c546518b0be91de9cacc98122a/msgpack-1.0.4.tar.gz
python-msgpack_dist_sum  := f5d869c18f030202eb412f08b28d2afeea553d6613aee89e200d7aca7ef01f5f
python-msgpack_dist_name := $(notdir $(python-msgpack_dist_url))

define fetch_python-msgpack_dist
$(call _download,$(python-msgpack_dist_url),$(FETCHDIR)/$(python-msgpack_dist_name).tmp)
cat $(FETCHDIR)/$(python-msgpack_dist_name).tmp | \
	sha256sum --check --status <(echo "$(python-msgpack_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(python-msgpack_dist_name).tmp,\
          $(FETCHDIR)/$(python-msgpack_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(python-msgpack_dist_name)'
endef

# As fetch_python-msgpack_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(python-msgpack_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,python-msgpack,python-msgpack_dist_name,fetch_python-msgpack_dist)

define xtract_python-msgpack
$(call rmrf,$(srcdir)/python-msgpack)
$(call untar,$(srcdir)/python-msgpack,\
             $(FETCHDIR)/$(python-msgpack_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,python-msgpack,xtract_python-msgpack)

$(call gen_dir_rules,python-msgpack)

# $(1): targets base name / module name
define python-msgpack_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-python-msgpack,stage-python)
$(call gen_check_deps,stage-python-msgpack,stage-pytest)

check_stage-python-msgpack = $(call python-msgpack_check_cmds,\
                                    stage-python-msgpack)
$(call gen_python_module_rules,stage-python-msgpack,\
                               python-msgpack,\
                               $(stagedir),\
                               ,\
                               check_stage-python-msgpack)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-python-msgpack,stage-python)
$(call gen_check_deps,final-python-msgpack,stage-pytest)

check_final-python-msgpack = $(call python-msgpack_check_cmds,\
                                    final-python-msgpack)
$(call gen_python_module_rules,final-python-msgpack,python-msgpack,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-python-msgpack)
