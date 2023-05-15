################################################################################
# libxslt modules
################################################################################

libxslt_dist_url  := https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.37.tar.xz
libxslt_dist_sum  := a4e477d2bb918b7d01945e2c7491c3a4aae799dc1602bbd13de55c8a5052e210a20bc45115347eae44473c8b1d03dbc5e4a2aa18c2218f1fdfd376d87cd501ca
libxslt_dist_name := $(notdir $(libxslt_dist_url))
libxslt_vers      := $(patsubst libxslt-%.tar.xz,%,$(libxslt_dist_name))
libxslt_brief     := XSLT 1.0 processing library
libxslt_home      := http://xmlsoft.org/xslt/

define libxslt_desc
XSLT is an XML language for defining transformations of XML files from XML to
some other arbitrary format, such as XML, HTML, plain text, etc.  using standard
XSLT stylesheets. libxslt is a C library which implements XSLT version 1.0.
endef

define fetch_libxslt_dist
$(call download_csum,$(libxslt_dist_url),\
                     $(libxslt_dist_name),\
                     $(libxslt_dist_sum))
endef
$(call gen_fetch_rules,libxslt,libxslt_dist_name,fetch_libxslt_dist)

define xtract_libxslt
$(call rmrf,$(srcdir)/libxslt)
$(call untar,$(srcdir)/libxslt,\
             $(FETCHDIR)/$(libxslt_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libxslt,xtract_libxslt)

$(call gen_dir_rules,libxslt)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
#
# libxslt check target MUST be run from top-level source tree...
define libxslt_config_cmds
$(RSYNC) --archive --delete $(srcdir)/libxslt/ $(builddir)/$(strip $(1))
cd $(builddir)/$(strip $(1)) && \
./configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libxslt_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define libxslt_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libxslt_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libxslt_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define libxslt_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

libxslt_common_config_args := --enable-silent-rules \
                              --enable-static \
                              --enable-shared \
                              --with-gnu-ld \
                              --with-python \
                              --with-crypto \
                              --with-plugins \
                              --with-libxml-prefix="$(stagedir)"

################################################################################
# Staging definitions
################################################################################

libxslt_stage_config_args := $(libxslt_common_config_args) \
                             MISSING='true' \
                             $(stage_config_flags)

$(call gen_deps,stage-libxslt,stage-python \
                              stage-libxml2 \
                              stage-openssl \
                              stage-pkg-config)
$(call gen_check_deps,stage-libxslt,stage-perl)

config_stage-libxslt       = $(call libxslt_config_cmds,\
                                    stage-libxslt,\
                                    $(stagedir),\
                                    $(libxslt_stage_config_args))
build_stage-libxslt        = $(call libxslt_build_cmds,stage-libxslt)
clean_stage-libxslt        = $(call libxslt_clean_cmds,stage-libxslt)
install_stage-libxslt      = $(call libxslt_install_cmds,stage-libxslt)
uninstall_stage-libxslt    = $(call libxslt_uninstall_cmds,stage-libxslt,\
                                                           $(stagedir))
check_stage-libxslt        = $(call libxslt_check_cmds,stage-libxslt)

$(call gen_config_rules_with_dep,stage-libxslt,libxslt,config_stage-libxslt)
$(call gen_clobber_rules,stage-libxslt)
$(call gen_build_rules,stage-libxslt,build_stage-libxslt)
$(call gen_clean_rules,stage-libxslt,clean_stage-libxslt)
$(call gen_install_rules,stage-libxslt,install_stage-libxslt)
$(call gen_uninstall_rules,stage-libxslt,uninstall_stage-libxslt)
$(call gen_check_rules,stage-libxslt,check_stage-libxslt)
$(call gen_dir_rules,stage-libxslt)

################################################################################
# Final definitions
################################################################################

libxslt_final_config_args := $(libxslt_common_config_args) \
                             $(final_config_flags) \
                             LT_SYS_LIBRARY_PATH="$(stagedir)/lib"

$(call gen_deps,final-libxslt,stage-python \
                              stage-libxml2 \
                              stage-openssl \
                              stage-texinfo \
                              stage-pkg-config)
$(call gen_check_deps,final-libxslt,stage-perl)

config_final-libxslt       = $(call libxslt_config_cmds,\
                                    final-libxslt,\
                                    $(PREFIX),\
                                    $(libxslt_final_config_args))
build_final-libxslt        = $(call libxslt_build_cmds,final-libxslt)
clean_final-libxslt        = $(call libxslt_clean_cmds,final-libxslt)
install_final-libxslt      = $(call libxslt_install_cmds,final-libxslt,\
                                    $(finaldir))
uninstall_final-libxslt    = $(call libxslt_uninstall_cmds,\
                                    final-libxslt,\
                                    $(PREFIX),\
                                    $(finaldir))
check_final-libxslt        = $(call libxslt_check_cmds,final-libxslt)

$(call gen_config_rules_with_dep,final-libxslt,libxslt,config_final-libxslt)
$(call gen_clobber_rules,final-libxslt)
$(call gen_build_rules,final-libxslt,build_final-libxslt)
$(call gen_clean_rules,final-libxslt,clean_final-libxslt)
$(call gen_install_rules,final-libxslt,install_final-libxslt)
$(call gen_uninstall_rules,final-libxslt,uninstall_final-libxslt)
$(call gen_check_rules,final-libxslt,check_final-libxslt)
$(call gen_dir_rules,final-libxslt)
