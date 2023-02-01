breathe_dist_url  := https://github.com/breathe-doc/breathe/archive/refs/tags/v4.34.0.tar.gz
breathe_sig_url   := https://github.com/breathe-doc/breathe/releases/download/v4.34.0/breathe-4.34.0.tar.gz.sig
breathe_dist_name := $(patsubst v%,breathe-,$(notdir $(breathe_dist_url)))

define fetch_breathe_dist
$(call download_verify_detach,$(breathe_dist_url), \
                              $(breathe_sig_url), \
                              $(FETCHDIR)/$(breathe_dist_name))
endef
$(call gen_fetch_rules,breathe,breathe_dist_name,fetch_breathe_dist)

define xtract_breathe
$(call rmrf,$(srcdir)/breathe)
$(call untar,$(srcdir)/breathe,\
             $(FETCHDIR)/$(breathe_dist_name),\
             --strip-components=1)
cd $(srcdir)/breathe && \
patch -p1 < $(PATCHDIR)/breathe-4.34.0-000-sphinx_6_version_support.patch
cd $(srcdir)/breathe && \
patch -p1 < $(PATCHDIR)/breathe-4.34.0-001-fix_test_mock_memo.patch
endef
$(call gen_xtract_rules,breathe,xtract_breathe)

$(call gen_dir_rules,breathe)

# $(1): targets base name / module name
define breathe_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-breathe,stage-sphinx)
$(call gen_check_deps,stage-breathe,stage-breathe stage-pytest)

check_stage-breathe = $(call breathe_check_cmds,stage-breathe)
$(call gen_python_module_rules,stage-breathe,\
                               breathe,\
                               $(stagedir),\
                               ,\
                               check_stage-breathe)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-breathe,stage-sphinx)
$(call gen_check_deps,final-breathe,stage-breathe stage-pytest)

check_final-breathe = $(call breathe_check_cmds,final-breathe)
$(call gen_python_module_rules,final-breathe,breathe,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-breathe)
