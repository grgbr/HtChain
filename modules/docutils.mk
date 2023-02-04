################################################################################
# docutils Python modules
################################################################################

docutils_dist_url  := https://files.pythonhosted.org/packages/6b/5c/330ea8d383eb2ce973df34d1239b3b21e91cd8c865d21ff82902d952f91f/docutils-0.19.tar.gz
docutils_dist_sum  := fb904a899f2b6f3c07c5079577bd7c52a3182cb85f6a4149391e523498df15bfa317f0c04095b890beeb3f89c2b444875a2a609d880ac4d7fbc3125e46b37ea5
docutils_dist_name := $(notdir $(docutils_dist_url))
docutils_vers      := $(patsubst docutils-%.tar.gz,%,$(docutils_dist_name))
docutils_brief     := Python_ text processing system for reStructuredText
docutils_home      := https://docutils.sourceforge.io/

define docutils_desc
reStructuredText is an easy-to-read, what-you-see-is-what-you-get plaintext
markup syntax and parser system. It is useful for in-line program documentation
(such as Python_ docstrings), for quickly creating simple web pages, and for
standalone documents.

The purpose of the Docutils project is to create a set of tools for processing
reStructuredText documentation into useful formats, such as HTML, LaTeX, ODT or
Unix manpages.
endef

define fetch_docutils_dist
$(call download_csum,$(docutils_dist_url),\
                     $(FETCHDIR)/$(docutils_dist_name),\
                     $(docutils_dist_sum))
endef
$(call gen_fetch_rules,docutils,docutils_dist_name,fetch_docutils_dist)

define xtract_docutils
$(call rmrf,$(srcdir)/docutils)
$(call untar,$(srcdir)/docutils,\
             $(FETCHDIR)/$(docutils_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,docutils,xtract_docutils)

$(call gen_dir_rules,docutils)

# $(1): targets base name / module name
define docutils_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) -s $(builddir)/$(strip $(1))/test/alltests.py --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-docutils,stage-python)

check_stage-docutils = $(call docutils_check_cmds,stage-docutils)
$(call gen_python_module_rules,stage-docutils,\
                               docutils,\
                               $(stagedir),\
                               ,\
                               check_stage-docutils)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-docutils,stage-python)

check_final-docutils = $(call docutils_check_cmds,final-docutils)
$(call gen_python_module_rules,final-docutils,\
                               docutils,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-docutils)
