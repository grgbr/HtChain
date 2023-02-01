cython_dist_url  := https://files.pythonhosted.org/packages/dc/f6/e8e302f9942cbebede88b1a0c33d0be3a738c3ac37abae87254d58ffc51c/Cython-0.29.33.tar.gz
cython_dist_sum  := 5040764c4a4d2ce964a395da24f0d1ae58144995dab92c6b96f44c3f4d72286a
cython_dist_name := $(notdir $(cython_dist_url))

define fetch_cython_dist
$(call _download,$(cython_dist_url),$(FETCHDIR)/$(cython_dist_name).tmp)
cat $(FETCHDIR)/$(cython_dist_name).tmp | \
	sha256sum --check --status <(echo "$(cython_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(cython_dist_name).tmp,\
          $(FETCHDIR)/$(cython_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(cython_dist_name)'
endef

# As fetch_cython_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(cython_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,cython,cython_dist_name,fetch_cython_dist)

define xtract_cython
$(call rmrf,$(srcdir)/cython)
$(call untar,$(srcdir)/cython,\
             $(FETCHDIR)/$(cython_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cython,xtract_cython)

$(call gen_dir_rules,cython)

# $(1): targets base name / module name
define cython_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) runtests.py -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cython,stage-python)

check_stage-cython = $(call cython_check_cmds,stage-cython)
$(call gen_python_module_rules,stage-cython,\
                               cython,\
                               $(stagedir), \
                               ,\
                               check_stage-cython)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-cython,stage-python)

check_final-cython = $(call cython_check_cmds,final-cython)
$(call gen_python_module_rules,final-cython,\
                               cython,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-cython)
