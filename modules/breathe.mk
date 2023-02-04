################################################################################
# breathe modules
################################################################################

breathe_dist_url  := https://github.com/breathe-doc/breathe/archive/refs/tags/v4.34.0.tar.gz
breathe_dist_sum  := 7f3134575f1b8c4d7c96ebc735e33f656b5c6046de3fa2aee95d5e895fb33f0a83fb4b1c64dd69b9deca20b785868b42d6b1d5e39741500ff5f9d82bf3f130b4
breathe_dist_name := $(patsubst v%,breathe-%,$(notdir $(breathe_dist_url)))
breathe_vers      := $(patsubst breathe-%.tar.gz,%,$(breathe_dist_name))
breathe_brief     := Sphinx_ autodox support for languages with doxygen support
breathe_home      := https://github.com/michaeljones/breathe

define breathe_desc
Breathe provides a bridge between the Sphinx_ and doxygen_ documentation
systems. It enables Sphinx_ to generate autodoc for languages other than Python_
with the help of doxygen_. It also allows one to embed reStructuredText in
doxygen markup.
endef

define fetch_breathe_dist
$(call download_csum,$(breathe_dist_url),\
                     $(FETCHDIR)/$(breathe_dist_name),\
                     $(breathe_dist_sum))
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
