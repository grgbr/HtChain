################################################################################
# libarchive modules
################################################################################

libarchive_dist_url  := https://www.libarchive.org/downloads/libarchive-3.6.1.tar.xz
libarchive_dist_sum  := 2e5a72edc468080c0e8f29e07d9c33826ffb246fa040ec42399bedeecf698b7555f69ffd15057ad79c0f50cd4926d43174599d99632b1b99ec6cd159c43a70b8
libarchive_dist_name := $(notdir $(libarchive_dist_url))
libarchive_vers      := $(patsubst libarchive-%.tar.xz,%,$(libarchive_dist_name))
libarchive_brief     := Multi-format archive and compression
libarchive_home      := https://www.libarchive.org/

define libarchive_desc
The libarchive library provides a flexible interface for reading and writing
archives in various formats such as tar and cpio. libarchive also supports
reading and writing archives compressed using various compression filters such
as gzip and bzip2. The library is inherently stream-oriented; readers serially
iterate through the archive, writers serially add things to the archive.

Archive formats supported are:

* tar (read and write, including GNU extensions)
* pax (read and write, including GNU and star extensions)
* cpio (read and write, including odc and newc variants)
* iso9660 (read and write, including Joliet and Rockridge extensions, with
  some limitations)
* zip (read only, with some limitations, uses zlib)
* mtree (read and write)
* shar (write only)
* ar (read and write, including BSD and GNU/SysV variants)
* empty (read only; in particular, note that no other format will accept an
  empty file)
* raw (read only)
* xar (read only)
* rar (read only, with some limitations)
* 7zip (read and write, with some limitations)

Filters supported are:

* gzip (read and write, uses zlib)
* bzip2 (read and write, uses bzlib)
* compress (read and write, uses an internal implementation)
* uudecode (read only)
* separate command-line compressors with fixed-signature auto-detection
* xz and lzma (read and write using liblzma)
* zstandard (read and write using libzstd)
endef

define fetch_libarchive_dist
$(call download_csum,$(libarchive_dist_url),\
                     $(FETCHDIR)/$(libarchive_dist_name),\
                     $(libarchive_dist_sum))
endef
$(call gen_fetch_rules,libarchive,libarchive_dist_name,fetch_libarchive_dist)

define xtract_libarchive
$(call rmrf,$(srcdir)/libarchive)
$(call untar,$(srcdir)/libarchive,\
             $(FETCHDIR)/$(libarchive_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libarchive,xtract_libarchive)

$(call gen_dir_rules,libarchive)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libarchive_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libarchive/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libarchive_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define libarchive_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libarchive_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libarchive_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define libarchive_check_cmds
+env LD_LIBRARY_PATH="$(stage_lib_path)" \
 $(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

libarchive_common_config_args := --enable-silent-rules \
                                 --enable-shared \
                                 --enable-static \
                                 --enable-xattr \
                                 --enable-acl \
                                 --with-zlib \
                                 --with-bz2lib \
                                 --with-lz4 \
                                 --with-zstd \
                                 --with-lzma \
                                 --with-lzo2 \
                                 --with-openssl \
                                 --with-xml2

################################################################################
# Staging definitions
################################################################################

libarchive_stage_config_args := $(libarchive_common_config_args) \
                                MISSING='true' \
                                $(stage_config_flags)

$(call gen_deps,stage-libarchive,stage-zlib \
                                 stage-acl \
                                 stage-bzip2 \
                                 stage-lz4 \
                                 stage-zstd \
                                 stage-xz-utils \
                                 stage-lzo \
                                 stage-openssl \
                                 stage-libxml2 \
                                 stage-icu4c)

config_stage-libarchive       = $(call libarchive_config_cmds,\
                                       stage-libarchive,\
                                       $(stagedir),\
                                       $(libarchive_stage_config_args))
build_stage-libarchive        = $(call libarchive_build_cmds,stage-libarchive)
clean_stage-libarchive        = $(call libarchive_clean_cmds,stage-libarchive)
install_stage-libarchive      = $(call libarchive_install_cmds,stage-libarchive)
uninstall_stage-libarchive    = $(call libarchive_uninstall_cmds,\
                                       stage-libarchive,\
                                       $(stagedir))
check_stage-libarchive        = $(call libarchive_check_cmds,stage-libarchive)

$(call gen_config_rules_with_dep,stage-libarchive,libarchive,\
                                                  config_stage-libarchive)
$(call gen_clobber_rules,stage-libarchive)
$(call gen_build_rules,stage-libarchive,build_stage-libarchive)
$(call gen_clean_rules,stage-libarchive,clean_stage-libarchive)
$(call gen_install_rules,stage-libarchive,install_stage-libarchive)
$(call gen_uninstall_rules,stage-libarchive,uninstall_stage-libarchive)
$(call gen_check_rules,stage-libarchive,check_stage-libarchive)
$(call gen_dir_rules,stage-libarchive)

################################################################################
# Final definitions
################################################################################

libarchive_final_config_args := $(libarchive_common_config_args) \
                                $(final_config_flags) \
                                LD_LIBRARY_PATH="$(stage_lib_path)" \
                                LT_SYS_LIBRARY_PATH="$(stagedir)/lib"

$(call gen_deps,final-libarchive,stage-zlib \
                                 stage-acl \
                                 stage-bzip2 \
                                 stage-lz4 \
                                 stage-zstd \
                                 stage-xz-utils \
                                 stage-lzo \
                                 stage-openssl \
                                 stage-libxml2 \
                                 stage-icu4c)

config_final-libarchive       = $(call libarchive_config_cmds,\
                                       final-libarchive,\
                                       $(PREFIX),\
                                       $(libarchive_final_config_args))
build_final-libarchive        = $(call libarchive_build_cmds,final-libarchive)
clean_final-libarchive        = $(call libarchive_clean_cmds,final-libarchive)
install_final-libarchive      = $(call libarchive_install_cmds,\
                                       final-libarchive,\
                                       $(finaldir))
uninstall_final-libarchive    = $(call libarchive_uninstall_cmds,\
                                       final-libarchive,\
                                       $(PREFIX),\
                                       $(finaldir))
check_final-libarchive        = $(call libarchive_check_cmds,final-libarchive)

$(call gen_config_rules_with_dep,final-libarchive,libarchive,\
                                                  config_final-libarchive)
$(call gen_clobber_rules,final-libarchive)
$(call gen_build_rules,final-libarchive,build_final-libarchive)
$(call gen_clean_rules,final-libarchive,clean_final-libarchive)
$(call gen_install_rules,final-libarchive,install_final-libarchive)
$(call gen_uninstall_rules,final-libarchive,uninstall_final-libarchive)
$(call gen_check_rules,final-libarchive,check_final-libarchive)
$(call gen_dir_rules,final-libarchive)
