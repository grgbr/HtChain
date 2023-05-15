################################################################################
# help2man modules
################################################################################

help2man_dist_url  := https://ftp.gnu.org/gnu/help2man/help2man-1.49.2.tar.xz
help2man_dist_sum  := cb8f9f923263d7160a27a7924ae559aba93d7258167888eb9e0e3e97a2014297b8d739b2bb7869acbf586354d099bd91d85f8208b901bce5ba0c5ad4b6abd6d5
help2man_dist_name := $(notdir $(help2man_dist_url))
help2man_vers      := $(patsubst help2man-%.tar.xz,%,$(help2man_dist_name))
help2man_brief     := Automatic manpage generator
help2man_home      := https://www.gnu.org/software/help2man/

define help2man_desc
Program to create simple man pages from the --help and --version output of other
programs.

Since most GNU documentation is now in ``info`` format, this provides a way to
generate a placeholder man page pointing to that resource while still providing
some useful information.
endef

define fetch_help2man_dist
$(call download_csum,$(help2man_dist_url),\
                     $(help2man_dist_name),\
                     $(help2man_dist_sum))
endef
$(call gen_fetch_rules,help2man,help2man_dist_name,fetch_help2man_dist)

define xtract_help2man
$(call rmrf,$(srcdir)/help2man)
$(call untar,$(srcdir)/help2man,\
             $(FETCHDIR)/$(help2man_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,help2man,xtract_help2man)

$(call gen_dir_rules,help2man)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define help2man_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/help2man/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define help2man_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define help2man_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define help2man_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define help2man_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

################################################################################
# Staging definitions
################################################################################

help2man_stage_config_args := --disable-nls \
                              $(stage_config_flags)

$(call gen_deps,stage-help2man,stage-perl stage-cpan-gettext)

config_stage-help2man       = $(call help2man_config_cmds,\
                                     stage-help2man,\
                                     $(stagedir),\
                                     $(help2man_stage_config_args))
build_stage-help2man        = $(call help2man_build_cmds,stage-help2man)
clean_stage-help2man        = $(call help2man_clean_cmds,stage-help2man)
install_stage-help2man      = $(call help2man_install_cmds,stage-help2man)
uninstall_stage-help2man    = $(call help2man_uninstall_cmds,stage-help2man,\
                                                             $(stagedir))

$(call gen_config_rules_with_dep,stage-help2man,help2man,config_stage-help2man)
$(call gen_clobber_rules,stage-help2man)
$(call gen_build_rules,stage-help2man,build_stage-help2man)
$(call gen_clean_rules,stage-help2man,clean_stage-help2man)
$(call gen_install_rules,stage-help2man,install_stage-help2man)
$(call gen_uninstall_rules,stage-help2man,uninstall_stage-help2man)
$(call gen_no_check_rules,stage-help2man)
$(call gen_dir_rules,stage-help2man)

################################################################################
# Final definitions
################################################################################

help2man_final_config_args := --enable-nls \
                              $(final_config_flags)

$(call gen_deps,final-help2man,stage-perl stage-cpan-gettext)

config_final-help2man       = $(call help2man_config_cmds,\
                                     final-help2man,\
                                     $(PREFIX),\
                                     $(help2man_final_config_args))
build_final-help2man        = $(call help2man_build_cmds,final-help2man)
clean_final-help2man        = $(call help2man_clean_cmds,final-help2man)

define install_final-help2man
$(call help2man_install_cmds,final-help2man,$(finaldir))
$(call fixup_shebang,$(finaldir)$(PREFIX)/bin/help2man,$(PREFIX)/bin/perl -w)
endef

uninstall_final-help2man    = $(call help2man_uninstall_cmds,\
                                     final-help2man,\
                                     $(PREFIX),\
                                     $(finaldir))

$(call gen_config_rules_with_dep,final-help2man,help2man,config_final-help2man)
$(call gen_clobber_rules,final-help2man)
$(call gen_build_rules,final-help2man,build_final-help2man)
$(call gen_clean_rules,final-help2man,clean_final-help2man)
$(call gen_install_rules,final-help2man,install_final-help2man)
$(call gen_uninstall_rules,final-help2man,uninstall_final-help2man)
$(call gen_no_check_rules,final-help2man)
$(call gen_dir_rules,final-help2man)
