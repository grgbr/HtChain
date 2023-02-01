################################################################################
# autoconf modules
#
# TODO:
# * also depends on perl
################################################################################

autoconf_dist_url  := https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz
autoconf_sig_url   := $(autoconf_dist_url).sig
autoconf_dist_name := $(notdir $(autoconf_dist_url))

define fetch_autoconf_dist
$(call download_verify_detach,$(autoconf_dist_url), \
                              $(autoconf_sig_url), \
                              $(FETCHDIR)/$(autoconf_dist_name))
endef
$(call gen_fetch_rules,autoconf,autoconf_dist_name,fetch_autoconf_dist)

define xtract_autoconf
$(call rmrf,$(srcdir)/autoconf)
$(call untar,$(srcdir)/autoconf,\
             $(FETCHDIR)/$(autoconf_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,autoconf,xtract_autoconf)

$(call gen_dir_rules,autoconf)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define autoconf_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/autoconf/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define autoconf_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         PATH="$(stagedir)/bin:$(PATH)" \
         $(verbose)
endef

# $(1): targets base name / module name
define autoconf_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define autoconf_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define autoconf_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define autoconf_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH="$(stagedir)/bin:$(PATH)"
endef

################################################################################
# Stage definitions
################################################################################

autoconf_stage_config_args  = --enable-silent-rules \
                              $(stage_config_flags)

$(call gen_deps,stage-autoconf,stage-m4 stage-perl)

config_stage-autoconf       = $(call autoconf_config_cmds,\
                                     stage-autoconf,\
                                     $(stagedir),\
                                     $(autoconf_stage_config_args))
build_stage-autoconf        = $(call autoconf_build_cmds,stage-autoconf)
clean_stage-autoconf        = $(call autoconf_clean_cmds,stage-autoconf)
install_stage-autoconf      = $(call autoconf_install_cmds,stage-autoconf)
uninstall_stage-autoconf    = $(call autoconf_uninstall_cmds,stage-autoconf,\
                                                             $(stagedir))
check_stage-autoconf        = $(call autoconf_check_cmds,stage-autoconf)

$(call gen_config_rules_with_dep,stage-autoconf,autoconf,config_stage-autoconf)
$(call gen_clobber_rules,stage-autoconf)
$(call gen_build_rules,stage-autoconf,build_stage-autoconf)
$(call gen_clean_rules,stage-autoconf,clean_stage-autoconf)
$(call gen_install_rules,stage-autoconf,install_stage-autoconf)
$(call gen_uninstall_rules,stage-autoconf,uninstall_stage-autoconf)
$(call gen_check_rules,stage-autoconf,check_stage-autoconf)
$(call gen_dir_rules,stage-autoconf)

################################################################################
# Final definitions
################################################################################

autoconf_final_config_args  = --enable-silent-rules \
                              $(final_config_flags) \
                              ac_cv_path_PERL="/usr/bin/env perl"

$(call gen_deps,final-autoconf,stage-m4 stage-perl)

config_final-autoconf       = $(call autoconf_config_cmds,\
                                     final-autoconf,\
                                     $(PREFIX),\
                                     $(autoconf_final_config_args))
build_final-autoconf        = $(call autoconf_build_cmds,final-autoconf)
clean_final-autoconf        = $(call autoconf_clean_cmds,final-autoconf)
install_final-autoconf      = $(call autoconf_install_cmds,final-autoconf,\
                                                           $(finaldir))
uninstall_final-autoconf    = $(call autoconf_uninstall_cmds,final-autoconf,\
                                                             $(PREFIX),\
                                                             $(finaldir))
check_final-autoconf        = $(call autoconf_check_cmds,final-autoconf)

$(call gen_config_rules_with_dep,final-autoconf,autoconf,config_final-autoconf)
$(call gen_clobber_rules,final-autoconf)
$(call gen_build_rules,final-autoconf,build_final-autoconf)
$(call gen_clean_rules,final-autoconf,clean_final-autoconf)
$(call gen_install_rules,final-autoconf,install_final-autoconf)
$(call gen_uninstall_rules,final-autoconf,uninstall_final-autoconf)
$(call gen_check_rules,final-autoconf,check_final-autoconf)
$(call gen_dir_rules,final-autoconf)
