################################################################################
# autogen modules
################################################################################

autogen_dist_url  := https://ftp.gnu.org/gnu/autogen/rel5.18.16/autogen-5.18.16.tar.xz
autogen_dist_sum  := 5f12c982dbe27873f5649a96049bf019ff183c90cc0c8a9196556b0ca02e72940cd422f6d6601f68cc7d8763b1124f2765c3b1a6335fc92ba07f84b03d2a53a1
autogen_dist_name := $(notdir $(autogen_dist_url))
autogen_vers      := $(patsubst autogen-%.tar.xz,%,$(autogen_dist_name))
autogen_brief     := Automated text file generator
autogen_home      := https://www.gnu.org/software/autogen/

define autogen_desc
AutoGen is a tool designed for generating program files that contain repetitive
text with varied substitutions. This is especially valuable if there are several
blocks of such text that must be kept synchronized.

Included with AutoGen is a tool that virtually eliminates the hassle of
processing options, keeping usage text up to date and so on. This tool allows
you to specify several program attributes, innumerable options and option
attributes, then it produces all the code necessary to parse and handle the
command line and initialization file options.

This package also ships with libopts library.
endef

define fetch_autogen_dist
$(call download_csum,$(autogen_dist_url),\
                     $(FETCHDIR)/$(autogen_dist_name),\
                     $(autogen_dist_sum))
endef
$(call gen_fetch_rules,autogen,autogen_dist_name,fetch_autogen_dist)

define xtract_autogen
$(call rmrf,$(srcdir)/autogen)
$(call untar,$(srcdir)/autogen,\
             $(FETCHDIR)/$(autogen_dist_name),\
             --strip-components=1)
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-000-guile_3.patch
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-001-fix_ag_macros_m4_syntax.patch
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-002-catch_race_error.patch
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-003-fix_gcc9_wrestrict.patch
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-004-fix_sprintf_overflow.patch
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-005-avoid_gcc_code_analysis_bug.patch
cd $(srcdir)/autogen && \
patch -p1 < $(PATCHDIR)/autogen-5.18.16-006-fix_getopt_test.patch
endef
$(call gen_xtract_rules,autogen,xtract_autogen)

$(call gen_dir_rules,autogen)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
#
# Disable dependency traking since it makes configure operation fail with the
# following error:
#     "Something went wrong bootstrapping makefile fragments for automatic
#      dependency tracking..."
# Don't bother fixing it since we do not really need dependency tracking (we
# only build once after all). I suspect this is related to automake version
# mismatch and we should probably run an autoupdate cycle...
#
# Also use MISSING=true to skip automatic Makefile generation based on
# autotools.
define autogen_config_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
$(srcdir)/autogen/configure --prefix='$(strip $(2))' \
                            --disable-dependency-tracking \
                            MISSING='true' \
                            $(3) \
                            $(verbose)
endef

# $(1): targets base name / module name
define autogen_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define autogen_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define autogen_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define autogen_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define autogen_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

autogen_common_config_args := --enable-silent-rules \
                              --disable-rpath \
                              --enable-shared \
                              --enable-static \
                              --enable-timeout=78 \
                              --with-libxml2 \
                              --with-packager='$(PKGNAME)' \
                              --with-packager-version='$(version)' \
                              GUILE="$(stagedir)/bin/guile"

################################################################################
# Staging definitions
################################################################################

autogen_stage_config_args := $(autogen_common_config_args) \
                             --disable-nls \
                             $(stage_config_flags)

$(call gen_deps,stage-autogen,\
                stage-guile \
                stage-libxml2 \
                stage-automake \
                stage-libtool \
                stage-chrpath)

config_stage-autogen       = $(call autogen_config_cmds,\
                                    stage-autogen,\
                                    $(stagedir),\
                                    $(autogen_stage_config_args))
build_stage-autogen        = $(call autogen_build_cmds,stage-autogen)
clean_stage-autogen        = $(call autogen_clean_cmds,stage-autogen)

define install_stage-autogen
$(call autogen_install_cmds,stage-autogen)
$(stage_chrpath) --replace "$(stage_lib_path)" \
                 $(stagedir)/bin/autogen \
                 $(verbose)
$(stage_chrpath) --replace "$(stage_lib_path)" \
                 $(stagedir)/bin/columns \
                 $(verbose)
$(stage_chrpath) --replace "$(stage_lib_path)" \
                 $(stagedir)/bin/getdefs \
                 $(verbose)
$(stage_chrpath) --replace "$(stage_lib_path)" \
                 $(stagedir)/bin/xml2ag \
                 $(verbose)
endef

uninstall_stage-autogen    = $(call autogen_uninstall_cmds,stage-autogen,\
                                                           $(stagedir))
check_stage-autogen        = $(call autogen_check_cmds,stage-autogen)

$(call gen_config_rules_with_dep,stage-autogen,autogen,config_stage-autogen)
$(call gen_clobber_rules,stage-autogen)
$(call gen_build_rules,stage-autogen,build_stage-autogen)
$(call gen_clean_rules,stage-autogen,clean_stage-autogen)
$(call gen_install_rules,stage-autogen,install_stage-autogen)
$(call gen_uninstall_rules,stage-autogen,uninstall_stage-autogen)
$(call gen_check_rules,stage-autogen,check_stage-autogen)
$(call gen_dir_rules,stage-autogen)

################################################################################
# Final definitions
################################################################################

autogen_final_config_args := $(autogen_common_config_args) \
                             --enable-nls \
                             $(final_config_flags)

$(call gen_deps,final-autogen,\
                stage-guile \
                stage-libxml2 \
                stage-automake \
                stage-libtool \
                stage-chrpath)

config_final-autogen       = $(call autogen_config_cmds,\
                                    final-autogen,\
                                    $(PREFIX),\
                                    $(autogen_final_config_args))
build_final-autogen        = $(call autogen_build_cmds,final-autogen)
clean_final-autogen        = $(call autogen_clean_cmds,final-autogen)

final-autogen_perl_fixups := share/autogen/mdoc2texi \
                             share/autogen/mdoc2man \
                             share/autogen/man2mdoc

final-autogen_rpath_fixups := bin/autogen \
                              bin/columns \
                              bin/getdefs \
                              bin/xml2ag

define install_final-autogen
$(call autogen_install_cmds,final-autogen,$(finaldir))
$(call fixup_shebang,$(addprefix $(finaldir)$(PREFIX)/,\
                                 $(final-autogen_perl_fixups)),\
                     $(PREFIX)/bin/perl)
$(call fixup_rpath,$(addprefix $(finaldir)$(PREFIX)/,\
                               $(final-autogen_rpath_fixups)),\
                   $(final_lib_path))
endef

uninstall_final-autogen    = $(call autogen_uninstall_cmds,final-autogen,\
                                                           $(PREFIX),\
                                                           $(finaldir))
check_final-autogen        = $(call autogen_check_cmds,final-autogen)

$(call gen_config_rules_with_dep,final-autogen,autogen,config_final-autogen)
$(call gen_clobber_rules,final-autogen)
$(call gen_build_rules,final-autogen,build_final-autogen)
$(call gen_clean_rules,final-autogen,clean_final-autogen)
$(call gen_install_rules,final-autogen,install_final-autogen)
$(call gen_uninstall_rules,final-autogen,uninstall_final-autogen)
$(call gen_check_rules,final-autogen,check_final-autogen)
$(call gen_dir_rules,final-autogen)
