################################################################################
# source-highlight modules
################################################################################

source-highlight_dist_url  := https://ftp.gnu.org/gnu/src-highlite/source-highlight-3.1.9.tar.gz
source-highlight_dist_sum  := d8e154e9a5d62c77807e4e5d36c0faed5ce2964291be5f8b83e2968a6de52229503689a4ca2109a717ae2632a14b63ec937ca0430c91684c72063f6bc0294195
source-highlight_dist_name := $(notdir $(source-highlight_dist_url))
source-highlight_vers      := $(patsubst source-highlight-%.tar.gz,%,$(source-highlight_dist_name))
source-highlight_brief     := Convert source code to syntax highlighted document
source-highlight_home      := http://www.gnu.org/software/src-highlite/

define source-highlight_desc
This program, given a source file, produces a document with syntax highlighting.

It supports syntax highlighting for over 100 file formats, including major
programming languages, markup formats, and configuration file formats. For
output, the following formats are supported: HTML, XHTML, LaTeX, Texinfo_, ANSI
color escape sequences, and DocBook.
endef

define fetch_source-highlight_dist
$(call download_csum,$(source-highlight_dist_url),\
                     $(FETCHDIR)/$(source-highlight_dist_name),\
                     $(source-highlight_dist_sum))
endef
$(call gen_fetch_rules,source-highlight,\
                       source-highlight_dist_name,\
                       fetch_source-highlight_dist)

define xtract_source-highlight
$(call rmrf,$(srcdir)/source-highlight)
$(call untar,$(srcdir)/source-highlight,\
             $(FETCHDIR)/$(source-highlight_dist_name),\
             --strip-components=1)
cd $(srcdir)/source-highlight && \
patch -p1 < $(PATCHDIR)/source-highlight-3.1.9-gcc11.patch
cd $(srcdir)/source-highlight && \
patch -p1 < $(PATCHDIR)/source-highlight-3.1.9-gcc12.patch
endef
$(call gen_xtract_rules,source-highlight,xtract_source-highlight)

$(call gen_dir_rules,source-highlight)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define source-highlight_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/source-highlight/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define source-highlight_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         LD_LIBRARY_PATH='$(stage_lib_path)' \
         $(verbose)
endef

# $(1): targets base name / module name
define source-highlight_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build /install prefix
# $(3): optional install destination directory
define source-highlight_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         LD_LIBRARY_PATH='$(stage_lib_path)' \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define source-highlight_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define source-highlight_check_cmds
+$(MAKE) -j1 \
         --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

source-highlight_common_config_args := --enable-silent-rules \
                                       --enable-shared \
                                       --enable-static \
                                       --with-boost-libdir='$(stagedir)/lib' \
                                       --with-boost-regex=boost_regex

################################################################################
# Staging definitions
################################################################################

source-highlight_stage_config_args := $(source-highlight_common_config_args) \
                                      ac_cv_path_HELP2MAN='' \
                                      ac_cv_path_CTAGS='' \
                                      MAKEINFO='' \
                                      MISSING='true' \
                                      $(stage_config_flags)

$(call gen_deps,stage-source-highlight,stage-flex stage-boost)

config_stage-source-highlight    = $(call source-highlight_config_cmds,\
                                          stage-source-highlight,\
                                          $(stagedir),\
                                          $(source-highlight_stage_config_args))
build_stage-source-highlight     = $(call source-highlight_build_cmds,\
                                          stage-source-highlight)
clean_stage-source-highlight     = $(call source-highlight_clean_cmds,\
                                          stage-source-highlight)
install_stage-source-highlight   = $(call source-highlight_install_cmds,\
                                          stage-source-highlight,\
                                          $(stagedir))
uninstall_stage-source-highlight = $(call source-highlight_uninstall_cmds,\
                                          stage-source-highlight,\
                                          $(stagedir))
check_stage-source-highlight     = $(call source-highlight_check_cmds,\
                                          stage-source-highlight)

$(call gen_config_rules_with_dep,stage-source-highlight,\
                                 source-highlight,\
                                 config_stage-source-highlight)
$(call gen_clobber_rules,stage-source-highlight)
$(call gen_build_rules,stage-source-highlight,build_stage-source-highlight)
$(call gen_clean_rules,stage-source-highlight,clean_stage-source-highlight)
$(call gen_install_rules,stage-source-highlight,install_stage-source-highlight)
$(call gen_uninstall_rules,stage-source-highlight,\
                           uninstall_stage-source-highlight)
$(call gen_check_rules,stage-source-highlight,check_stage-source-highlight)
$(call gen_dir_rules,stage-source-highlight)

################################################################################
# Final definitions
################################################################################

source-highlight_final_config_args := $(source-highlight_common_config_args) \
                                      --with-doxygen \
                                      ac_cv_path_CTAGS='' \
                                      $(final_config_flags)

$(call gen_deps,final-source-highlight,\
                stage-flex \
                stage-doxygen \
                stage-texinfo \
                stage-help2man \
                stage-boost)

config_final-source-highlight    = $(call source-highlight_config_cmds,\
                                          final-source-highlight,\
                                          $(PREFIX),\
                                          $(source-highlight_final_config_args))
build_final-source-highlight     = $(call source-highlight_build_cmds,\
                                          final-source-highlight)
clean_final-source-highlight     = $(call source-highlight_clean_cmds,\
                                          final-source-highlight)
install_final-source-highlight   = $(call source-highlight_install_cmds,\
                                          final-source-highlight,\
                                          $(PREFIX),\
                                          $(finaldir))
uninstall_final-source-highlight = $(call source-highlight_uninstall_cmds,\
                                          final-source-highlight,\
                                          $(PREFIX),\
                                          $(finaldir))
check_final-source-highlight     = $(call source-highlight_check_cmds,\
                                          final-source-highlight)

$(call gen_config_rules_with_dep,final-source-highlight,\
                                 source-highlight,\
                                 config_final-source-highlight)
$(call gen_clobber_rules,final-source-highlight)
$(call gen_build_rules,final-source-highlight,build_final-source-highlight)
$(call gen_clean_rules,final-source-highlight,clean_final-source-highlight)
$(call gen_install_rules,final-source-highlight,install_final-source-highlight)
$(call gen_uninstall_rules,final-source-highlight,\
                           uninstall_final-source-highlight)
$(call gen_check_rules,final-source-highlight,check_final-source-highlight)
$(call gen_dir_rules,final-source-highlight)
