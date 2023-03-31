################################################################################
# elfutils modules
################################################################################

elfutils_dist_url  := https://sourceware.org/elfutils/ftp/0.189/elfutils-0.189.tar.bz2
elfutils_dist_sum  := 93a877e34db93e5498581d0ab2d702b08c0d87e4cafd9cec9d6636dfa85a168095c305c11583a5b0fb79374dd93bc8d0e9ce6016e6c172764bcea12861605b71
elfutils_dist_name := $(notdir $(elfutils_dist_url))
elfutils_vers      := $(patsubst elfutils-%.tar.bz2,%,$(elfutils_dist_name))
elfutils_brief     := Library to read and write ELF files
elfutils_home      := https://sourceware.org/elfutils/

define elfutils_desc
Elfutils is a collection of utilities, including eu-ld (a linker), eu-nm (for
listing symbols from object files), eu-size (for listing the section sizes of an
object or archive file), eu-strip (for discarding symbols), eu-readelf (to see
the raw ELF file structures), and eu-elflint (to check for well-formed ELF
files).
endef

define fetch_elfutils_dist
$(call download_csum,$(elfutils_dist_url),\
                     $(FETCHDIR)/$(elfutils_dist_name),\
                     $(elfutils_dist_sum))
endef
$(call gen_fetch_rules,elfutils,elfutils_dist_name,fetch_elfutils_dist)

define xtract_elfutils
$(call rmrf,$(srcdir)/elfutils)
$(call untar,$(srcdir)/elfutils,\
             $(FETCHDIR)/$(elfutils_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,elfutils,xtract_elfutils)

$(call gen_dir_rules,elfutils)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define elfutils_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/elfutils/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define elfutils_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         PATH='$(stagedir)/bin:$(PATH)' \
         $(verbose)
endef

# $(1): targets base name / module name
define elfutils_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
    PATH='$(stagedir)/bin:$(PATH)' \
	clean \
	$(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define elfutils_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         PATH='$(stagedir)/bin:$(PATH)' \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define elfutils_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          PATH='$(stagedir)/bin:$(PATH)' \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): make flags
#
# Building with -DNDEBUG makes some variables unused since wrapped into
# assertion call. As elfutils is building its testsuite with the -Werror flag
# given to gcc, this makes elfutils build process fail.
# Get rid of -DNDEBUG from compile / link flags.
define elfutils_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)' \
         $(subst -DNDEBUG,,$(2))
endef

elfutils_common_config_args := --enable-silent-rules \
                               --enable-libdebuginfod \
                               --disable-debuginfod \
                               --with-zlib \
                               --with-bzlib \
                               --with-lzma \
                               --with-zstd

################################################################################
# Staging definitions
################################################################################

elfutils_stage_config_args := $(elfutils_common_config_args) \
                              --disable-nls \
                              MISSING='true' \
                              $(stage_config_flags)

$(call gen_deps,stage-elfutils,stage-zlib \
                               stage-bzip2 \
                               stage-pkg-config \
                               stage-zstd \
                               stage-curl \
                               stage-sqlite \
                               stage-libarchive)
$(call gen_check_deps,stage-elfutils,stage-dejagnu)

config_stage-elfutils       = $(call elfutils_config_cmds,\
                                     stage-elfutils,\
                                     $(stagedir),\
                                     $(elfutils_stage_config_args))
build_stage-elfutils        = $(call elfutils_build_cmds,stage-elfutils)
clean_stage-elfutils        = $(call elfutils_clean_cmds,stage-elfutils)
install_stage-elfutils      = $(call elfutils_install_cmds,stage-elfutils)
uninstall_stage-elfutils    = $(call elfutils_uninstall_cmds,\
                                     stage-elfutils,$(stagedir))
check_stage-elfutils        = $(call elfutils_check_cmds,stage-elfutils,\
                                                         $(stage_config_flags))

$(call gen_config_rules_with_dep,stage-elfutils,elfutils,config_stage-elfutils)
$(call gen_clobber_rules,stage-elfutils)
$(call gen_build_rules,stage-elfutils,build_stage-elfutils)
$(call gen_clean_rules,stage-elfutils,clean_stage-elfutils)
$(call gen_install_rules,stage-elfutils,install_stage-elfutils)
$(call gen_uninstall_rules,stage-elfutils,uninstall_stage-elfutils)
$(call gen_check_rules,stage-elfutils,check_stage-elfutils)
$(call gen_dir_rules,stage-elfutils)

################################################################################
# Final definitions
################################################################################

elfutils_final_config_args := $(elfutils_common_config_args) \
                              --enable-nls \
                              $(final_config_flags)

$(call gen_deps,final-elfutils,stage-zlib \
                               stage-bzip2 \
                               stage-pkg-config \
                               stage-zstd \
                               stage-curl \
                               stage-sqlite \
                               stage-libarchive)
$(call gen_check_deps,final-elfutils,stage-dejagnu)

config_final-elfutils       = $(call elfutils_config_cmds,\
                                     final-elfutils,\
                                     $(PREFIX),\
                                     $(elfutils_final_config_args))
build_final-elfutils        = $(call elfutils_build_cmds,final-elfutils)
clean_final-elfutils        = $(call elfutils_clean_cmds,final-elfutils)
install_final-elfutils      = $(call elfutils_install_cmds,final-elfutils,\
                                                           $(finaldir))
uninstall_final-elfutils    = $(call elfutils_uninstall_cmds,\
                                     final-elfutils,\
                                     $(PREFIX),\
                                     $(finaldir))
check_final-elfutils        = $(call elfutils_check_cmds,final-elfutils,\
                                                         $(final_config_flags))

$(call gen_config_rules_with_dep,final-elfutils,elfutils,config_final-elfutils)
$(call gen_clobber_rules,final-elfutils)
$(call gen_build_rules,final-elfutils,build_final-elfutils)
$(call gen_clean_rules,final-elfutils,clean_final-elfutils)
$(call gen_install_rules,final-elfutils,install_final-elfutils)
$(call gen_uninstall_rules,final-elfutils,uninstall_final-elfutils)
$(call gen_check_rules,final-elfutils,check_final-elfutils)
$(call gen_dir_rules,final-elfutils)
