################################################################################
# texinfo modules
################################################################################

texinfo_dist_url  := https://ftp.gnu.org/gnu/texinfo/texinfo-6.8.tar.xz
texinfo_dist_sum  := 0ff9290b14e4d83e32b889cfa24e6d065f98b2a764daf6b92c6c895fddbb35258398da6257c113220d5a4d886f7b54b09c4b117ca5eacfee6797f9bffde0f909
texinfo_dist_name := $(notdir $(texinfo_dist_url))
texinfo_vers      := $(patsubst texinfo-%.tar.xz,%,$(texinfo_dist_name))
texinfo_brief     := Documentation system for on-line information and printed output
texinfo_home      := https://www.gnu.org/software/texinfo/

define texinfo_desc
Texinfo is a documentation system that uses a single source file to produce both
on-line information and printed output.

Using Texinfo, you can create a printed document with the normal features of a
book, including chapters, sections, cross references, and indices.  From the
same Texinfo source file, you can create a menu-driven, on-line Info file with
nodes, menus, cross references, and indices.
endef

define fetch_texinfo_dist
$(call download_csum,$(texinfo_dist_url),\
                     $(FETCHDIR)/$(texinfo_dist_name),\
                     $(texinfo_dist_sum))
endef
$(call gen_fetch_rules,texinfo,texinfo_dist_name,fetch_texinfo_dist)

define xtract_texinfo
$(call rmrf,$(srcdir)/texinfo)
$(call untar,$(srcdir)/texinfo,\
             $(FETCHDIR)/$(texinfo_dist_name),\
             --strip-components=1)
cd $(srcdir)/texinfo && \
patch -p1 < $(PATCHDIR)/texinfo-6.8-000-find_working_locale_for_gettext.patch
endef
$(call gen_xtract_rules,texinfo,xtract_texinfo)

$(call gen_dir_rules,texinfo)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define texinfo_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/texinfo/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define texinfo_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define texinfo_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define texinfo_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define texinfo_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call rmf,$(strip $(3))$(strip $(2))/bin/makeinfo)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define texinfo_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH="$(stagedir)/bin:$(PATH)"
endef

texinfo_common_config_args := --enable-silent-rules \
                              --enable-threads \
                              --enable-perl-xs \
                              --enable-perl-api-texi-build

################################################################################
# Staging definitions
################################################################################

texinfo_stage_config_args := $(texinfo_common_config_args) \
                             --disable-nls \
                             HELP2MAN=true \
                             MAKEINFO=true \
                             XGETTEXT="$(stagedir)/bin/xgettext" \
                             MSGFMT="$(stagedir)/bin/msgfmt" \
                             GMSGFMT="$(stagedir)/bin/msgfmt" \
                             MSGMERGE="$(stagedir)/bin/msgmerge" \
                             $(stage_config_flags)

$(call gen_deps,stage-texinfo,\
                stage-perl stage-libunistring stage-ncurses stage-gettext)

config_stage-texinfo    = $(call texinfo_config_cmds,\
                                 stage-texinfo,\
                                 $(stagedir),\
                                 $(texinfo_stage_config_args))
build_stage-texinfo     = $(call texinfo_build_cmds,stage-texinfo)
clean_stage-texinfo     = $(call texinfo_clean_cmds,stage-texinfo)
install_stage-texinfo   = $(call texinfo_install_cmds,stage-texinfo)
uninstall_stage-texinfo = $(call texinfo_uninstall_cmds,\
                                 stage-texinfo,\
                                 $(stagedir))
check_stage-texinfo     = $(call texinfo_check_cmds,stage-texinfo)

$(call gen_config_rules_with_dep,stage-texinfo,texinfo,config_stage-texinfo)
$(call gen_clobber_rules,stage-texinfo)
$(call gen_build_rules,stage-texinfo,build_stage-texinfo)
$(call gen_clean_rules,stage-texinfo,clean_stage-texinfo)
$(call gen_install_rules,stage-texinfo,install_stage-texinfo)
$(call gen_uninstall_rules,stage-texinfo,uninstall_stage-texinfo)
$(call gen_check_rules,stage-texinfo,check_stage-texinfo)
$(call gen_dir_rules,stage-texinfo)

################################################################################
# Final definitions
################################################################################

texinfo_final_config_args := $(texinfo_common_config_args) \
                             --enable-nls \
                             $(final_config_flags)

$(call gen_deps,final-texinfo,stage-texinfo)

config_final-texinfo    = $(call texinfo_config_cmds,\
                                 final-texinfo,\
                                 $(PREFIX),\
                                 $(texinfo_final_config_args))
build_final-texinfo     = $(call texinfo_build_cmds,final-texinfo)
clean_final-texinfo     = $(call texinfo_clean_cmds,final-texinfo)
install_final-texinfo   = $(call texinfo_install_cmds,final-texinfo,$(finaldir))
uninstall_final-texinfo = $(call texinfo_uninstall_cmds,\
                                 final-texinfo,\
                                 $(PREFIX),\
                                 $(finaldir))
check_final-texinfo     = $(call texinfo_check_cmds,final-texinfo)

$(call gen_config_rules_with_dep,final-texinfo,texinfo,config_final-texinfo)
$(call gen_clobber_rules,final-texinfo)
$(call gen_build_rules,final-texinfo,build_final-texinfo)
$(call gen_clean_rules,final-texinfo,clean_final-texinfo)
$(call gen_install_rules,final-texinfo,install_final-texinfo)
$(call gen_uninstall_rules,final-texinfo,uninstall_final-texinfo)
$(call gen_check_rules,final-texinfo,check_final-texinfo)
$(call gen_dir_rules,final-texinfo)
