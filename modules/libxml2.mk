################################################################################
# libxml2 modules
################################################################################

libxml2_dist_url  := https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz
libxml2_dist_sum  := d08e6cafb289c499fdc5b3a12181e032a34f7a249bc66758859f964d3e71e19fd69be79921e1a9d8ab1e692d15b13f5fae95eeb10c3236974d89e218f5107606
libxml2_dist_name := $(notdir $(libxml2_dist_url))
libxml2_vers      := $(patsubst libxml2-%.tar.xz,%,$(libxml2_dist_name))
libxml2_brief     := GNOME XML library
libxml2_home      := http://xmlsoft.org

define libxml2_desc
XML is a metalanguage to let you design your own markup language. A regular
markup language defines a way to describe information in a certain class of
documents (eg HTML). XML lets you define your own customized markup languages
for many classes of document. It can do this because it\'s written in SGML, the
international standard metalanguage for markup languages.

This package provides a library providing an extensive API to handle such XML
data files.
endef

define fetch_libxml2_dist
$(call download_csum,$(libxml2_dist_url),\
                     $(FETCHDIR)/$(libxml2_dist_name),\
                     $(libxml2_dist_sum))
endef
$(call gen_fetch_rules,libxml2,libxml2_dist_name,fetch_libxml2_dist)

define xtract_libxml2
$(call rmrf,$(srcdir)/libxml2)
$(call untar,$(srcdir)/libxml2,\
             $(FETCHDIR)/$(libxml2_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libxml2,xtract_libxml2)

$(call gen_dir_rules,libxml2)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libxml2_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libxml2/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libxml2_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define libxml2_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libxml2_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libxml2_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Requires perl to run...
define libxml2_check_cmds
+env LD_LIBRARY_PATH="$(stage_lib_path)" \
 $(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

libxml2_common_config_args := --enable-silent-rules \
                              --enable-shared \
                              --enable-static \
                              --with-sysroot='$(stagedir)' \
                              --with-fexceptions \
                              --with-iconv \
                              --with-icu \
                              --with-python='$(stagedir)' \
                              --with-readline='$(stagedir)' \
                              --with-threads \
                              --with-zlib='$(stagedir)' \
                              --with-lzma='$(stagedir)' \
                              PATH="$(stagedir)/bin:$(PATH)"

################################################################################
# Staging definitions
################################################################################

libxml2_stage_config_args := $(libxml2_common_config_args) \
                             $(stage_config_flags)

$(call gen_deps,stage-libxml2,stage-icu4c \
                              stage-readline \
                              stage-zlib \
                              stage-xz-utils \
                              stage-pkg-config \
                              stage-python)

config_stage-libxml2    = $(call libxml2_config_cmds,\
                                 stage-libxml2,\
                                 $(stagedir),\
                                 $(libxml2_stage_config_args))
build_stage-libxml2     = $(call libxml2_build_cmds,stage-libxml2)
clean_stage-libxml2     = $(call libxml2_clean_cmds,stage-libxml2)
install_stage-libxml2   = $(call libxml2_install_cmds,stage-libxml2)
uninstall_stage-libxml2 = $(call libxml2_uninstall_cmds,stage-libxml2,\
                                                        $(stagedir))
check_stage-libxml2     = $(call libxml2_check_cmds,stage-libxml2)

$(call gen_config_rules_with_dep,stage-libxml2,libxml2,config_stage-libxml2)
$(call gen_clobber_rules,stage-libxml2)
$(call gen_build_rules,stage-libxml2,build_stage-libxml2)
$(call gen_clean_rules,stage-libxml2,clean_stage-libxml2)
$(call gen_install_rules,stage-libxml2,install_stage-libxml2)
$(call gen_uninstall_rules,stage-libxml2,uninstall_stage-libxml2)
$(call gen_check_rules,stage-libxml2,check_stage-libxml2)
$(call gen_dir_rules,stage-libxml2)

################################################################################
# Final definitions
################################################################################

libxml2_final_config_args := $(libxml2_common_config_args) \
                             $(final_config_flags) \
                             LT_SYS_LIBRARY_PATH="$(stagedir)/lib"

$(call gen_deps,final-libxml2,stage-icu4c \
                              stage-python \
                              stage-readline \
                              stage-zlib \
                              stage-xz-utils \
                              stage-pkg-config \
                              stage-python)

config_final-libxml2    = $(call libxml2_config_cmds,\
                                 final-libxml2,\
                                 $(PREFIX),\
                                 $(libxml2_final_config_args))
build_final-libxml2     = $(call libxml2_build_cmds,final-libxml2)
clean_final-libxml2     = $(call libxml2_clean_cmds,final-libxml2)
install_final-libxml2   = $(call libxml2_install_cmds,final-libxml2,$(finaldir))
uninstall_final-libxml2 = $(call libxml2_uninstall_cmds,final-libxml2,\
                                                        $(PREFIX),\
                                                        $(finaldir))
check_final-libxml2     = $(call libxml2_check_cmds,final-libxml2)

$(call gen_config_rules_with_dep,final-libxml2,libxml2,config_final-libxml2)
$(call gen_clobber_rules,final-libxml2)
$(call gen_build_rules,final-libxml2,build_final-libxml2)
$(call gen_clean_rules,final-libxml2,clean_final-libxml2)
$(call gen_install_rules,final-libxml2,install_final-libxml2)
$(call gen_uninstall_rules,final-libxml2,uninstall_final-libxml2)
$(call gen_check_rules,final-libxml2,check_final-libxml2)
$(call gen_dir_rules,final-libxml2)
