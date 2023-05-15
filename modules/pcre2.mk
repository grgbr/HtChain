################################################################################
# pcre2 modules
################################################################################

pcre2_dist_url  := https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.bz2
pcre2_dist_sum  := 72fbde87fecec3aa4b47225dd919ea1d55e97f2cbcf02aba26e5a0d3b1ffb58c25a80a9ef069eb99f9cf4e41ba9604ad06a7ec159870e1e875d86820e12256d3
pcre2_dist_name := $(notdir $(pcre2_dist_url))
pcre2_vers      := $(patsubst pcre2-%.tar.bz2,%,$(pcre2_dist_name))
pcre2_brief     := New Perl Compatible Regular Expression Library
pcre2_home      := https://pcre.org/

define pcre2_desc
This is PCRE2, the new implementation of PCRE, a library of functions to support
regular expressions whose syntax and semantics are as close as possible to those
of the Perl_ 5 language.
endef

define fetch_pcre2_dist
$(call download_csum,$(pcre2_dist_url),\
                     $(pcre2_dist_name),\
                     $(pcre2_dist_sum))
endef
$(call gen_fetch_rules,pcre2,pcre2_dist_name,fetch_pcre2_dist)

define xtract_pcre2
$(call rmrf,$(srcdir)/pcre2)
$(call untar,$(srcdir)/pcre2,\
             $(FETCHDIR)/$(pcre2_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pcre2,xtract_pcre2)

$(call gen_dir_rules,pcre2)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define pcre2_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/pcre2/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define pcre2_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         $(verbose)
endef

# $(1): targets base name / module name
define pcre2_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
	clean \
	$(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define pcre2_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define pcre2_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define pcre2_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

pcre2_common_config_args := --enable-silent-rules \
                            --enable-shared \
                            --enable-static \
                            --disable-debug \
                            --enable-jit \
                            --enable-unicode \
                            --enable-pcre2grep-libz \
                            --enable-pcre2grep-libbz2 \
                            --enable-pcre2test-libreadline

################################################################################
# Staging definitions
################################################################################

pcre2_stage_config_args := $(pcre2_common_config_args) \
                           MISSING='true' \
                           $(stage_config_flags)

$(call gen_deps,stage-pcre2,stage-zlib stage-bzip2 stage-readline)

config_stage-pcre2       = $(call pcre2_config_cmds,stage-pcre2,\
                                                    $(stagedir),\
                                                    $(pcre2_stage_config_args))
build_stage-pcre2        = $(call pcre2_build_cmds,stage-pcre2)
clean_stage-pcre2        = $(call pcre2_clean_cmds,stage-pcre2)
install_stage-pcre2      = $(call pcre2_install_cmds,stage-pcre2)
uninstall_stage-pcre2    = $(call pcre2_uninstall_cmds,stage-pcre2,$(stagedir))
check_stage-pcre2        = $(call pcre2_check_cmds,stage-pcre2)

$(call gen_config_rules_with_dep,stage-pcre2,pcre2,config_stage-pcre2)
$(call gen_clobber_rules,stage-pcre2)
$(call gen_build_rules,stage-pcre2,build_stage-pcre2)
$(call gen_clean_rules,stage-pcre2,clean_stage-pcre2)
$(call gen_install_rules,stage-pcre2,install_stage-pcre2)
$(call gen_uninstall_rules,stage-pcre2,uninstall_stage-pcre2)
$(call gen_check_rules,stage-pcre2,check_stage-pcre2)
$(call gen_dir_rules,stage-pcre2)

################################################################################
# Final definitions
################################################################################

pcre2_final_config_args := $(pcre2_common_config_args) \
                           $(final_config_flags)

$(call gen_deps,final-pcre2,stage-zlib stage-bzip2 stage-readline)

config_final-pcre2       = $(call pcre2_config_cmds,final-pcre2,\
                                                    $(PREFIX),\
                                                    $(pcre2_final_config_args))
build_final-pcre2        = $(call pcre2_build_cmds,final-pcre2)
clean_final-pcre2        = $(call pcre2_clean_cmds,final-pcre2)
install_final-pcre2      = $(call pcre2_install_cmds,final-pcre2,$(finaldir))
uninstall_final-pcre2    = $(call pcre2_uninstall_cmds,final-pcre2,\
                                                       $(PREFIX),\
                                                       $(finaldir))
check_final-pcre2        = $(call pcre2_check_cmds,final-pcre2)

$(call gen_config_rules_with_dep,final-pcre2,pcre2,config_final-pcre2)
$(call gen_clobber_rules,final-pcre2)
$(call gen_build_rules,final-pcre2,build_final-pcre2)
$(call gen_clean_rules,final-pcre2,clean_final-pcre2)
$(call gen_install_rules,final-pcre2,install_final-pcre2)
$(call gen_uninstall_rules,final-pcre2,uninstall_final-pcre2)
$(call gen_check_rules,final-pcre2,check_final-pcre2)
$(call gen_dir_rules,final-pcre2)
