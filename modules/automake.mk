################################################################################
# autoconf modules
################################################################################

automake_dist_url  := https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz
automake_sig_url   := $(automake_dist_url).sig
automake_dist_name := $(notdir $(automake_dist_url))

define fetch_automake_dist
$(call download_verify_detach,$(automake_dist_url), \
                              $(automake_sig_url), \
                              $(FETCHDIR)/$(automake_dist_name))
endef
$(call gen_fetch_rules,automake,automake_dist_name,fetch_automake_dist)

define xtract_automake
$(call rmrf,$(srcdir)/automake)
$(call untar,$(srcdir)/automake,\
             $(FETCHDIR)/$(automake_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,automake,xtract_automake)

$(call gen_dir_rules,automake)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define automake_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/automake/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define automake_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         PATH="$(stagedir)/bin:$(PATH)" \
         $(verbose)
endef

# $(1): targets base name / module name
define automake_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define automake_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
#
# Because, test result directories are created read-only, run a chmod command to
# make them read-write beforehand.
define automake_uninstall_cmds
$(CHMOD) --recursive u+rwx $(builddir)/$(strip $(1))
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define automake_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PERL="$(stage_perl)" \
         PATH="$(stagedir)/bin:$(PATH)"
endef

################################################################################
# Staging definitions
################################################################################

automake_stage_config_args := --enable-silent-rules \
                              $(stage_config_flags) \
                              PATH="$(stagedir)/bin:$(PATH)"

$(call gen_deps,stage-automake,stage-autoconf)
$(call gen_check_deps,stage-automake,stage-libtool stage-flex stage-dejagnu \
                                     stage-gettext stage-python stage-bison \
                                     stage-texinfo stage-help2man)

config_stage-automake       = $(call automake_config_cmds,\
                                     stage-automake,\
                                     $(stagedir),\
                                     $(automake_stage_config_args))
build_stage-automake        = $(call automake_build_cmds,stage-automake)
clean_stage-automake        = $(call automake_clean_cmds,stage-automake)
install_stage-automake      = $(call automake_install_cmds,stage-automake)
uninstall_stage-automake    = $(call automake_uninstall_cmds,stage-automake,\
                                                             $(stagedir))
check_stage-automake        = $(call automake_check_cmds,stage-automake)

$(call gen_config_rules_with_dep,stage-automake,automake,config_stage-automake)
$(call gen_clobber_rules,stage-automake)
$(call gen_build_rules,stage-automake,build_stage-automake)
$(call gen_clean_rules,stage-automake,clean_stage-automake)
$(call gen_install_rules,stage-automake,install_stage-automake)
$(call gen_uninstall_rules,stage-automake,uninstall_stage-automake)
$(call gen_check_rules,stage-automake,check_stage-automake)
$(call gen_dir_rules,stage-automake)

################################################################################
# Final definitions
################################################################################

automake_final_config_args := --enable-silent-rules \
                              $(final_config_flags) \
                              ac_cv_path_PERL="/usr/bin/env perl"

$(call gen_deps,final-automake,stage-autoconf stage-help2man)
$(call gen_check_deps,final-automake,stage-libtool stage-flex stage-dejagnu \
                                     stage-gettext stage-python stage-bison \
                                     stage-texinfo)

config_final-automake    = $(call automake_config_cmds,\
                                  final-automake,\
                                  $(PREFIX),\
                                  $(automake_final_config_args))
build_final-automake     = $(call automake_build_cmds,final-automake)
clean_final-automake     = $(call automake_clean_cmds,final-automake)
install_final-automake   = $(call automake_install_cmds,final-automake,\
                                                        $(finaldir))
uninstall_final-automake = $(call automake_uninstall_cmds,\
                                  final-automake,\
                                  $(PREFIX),\
                                  $(finaldir))
check_final-automake     = $(call automake_check_cmds,final-automake)

$(call gen_config_rules_with_dep,final-automake,automake,config_final-automake)
$(call gen_clobber_rules,final-automake)
$(call gen_build_rules,final-automake,build_final-automake)
$(call gen_clean_rules,final-automake,clean_final-automake)
$(call gen_install_rules,final-automake,install_final-automake)
$(call gen_uninstall_rules,final-automake,uninstall_final-automake)
$(call gen_check_rules,final-automake,check_final-automake)
$(call gen_dir_rules,final-automake)
