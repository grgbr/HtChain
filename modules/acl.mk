################################################################################
# acl modules
################################################################################

acl_dist_url  := http://download.savannah.nongnu.org/releases/acl/acl-2.3.1.tar.xz
acl_dist_sum  := 7d02f05d17305f8587ab485395b00c7fdb8e44c1906d0d04b70a43a3020803e8b2b8c707abb6147f794867dfa87bd51769c2d3e11a3db55ecbd2006a6e6231dc
acl_dist_name := $(notdir $(acl_dist_url))
acl_vers      := $(patsubst acl-%.tar.xz,%,$(acl_dist_name))
acl_brief     := POSIX Access Control Lists manipulation
acl_home      := https://savannah.nongnu.org/projects/acl/

define acl_desc
This package provides the library containing the POSIX 1003.1e draft standard 17
functions for manipulating access control lists.

It also provides the getfacl and setfacl utilities needed for manipulating
access control lists as wel as the chacl IRIX compatible utility.
endef

define fetch_acl_dist
$(call download_csum,$(acl_dist_url),\
                     $(FETCHDIR)/$(acl_dist_name),\
                     $(acl_dist_sum))
endef
$(call gen_fetch_rules,acl,acl_dist_name,fetch_acl_dist)

define xtract_acl
$(call rmrf,$(srcdir)/acl)
$(call untar,$(srcdir)/acl,\
             $(FETCHDIR)/$(acl_dist_name),\
             --strip-components=1)
cd $(srcdir)/acl && \
patch -p1 < $(PATCHDIR)/acl-2.3.1-000-fix_test_perl_interpreter.patch
endef
$(call gen_xtract_rules,acl,xtract_acl)

$(call gen_dir_rules,acl)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define acl_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/acl/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define acl_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define acl_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define acl_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define acl_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Requires perl to run. Thanks to patch above (see xtract_acl recipe), perl
# will be search from PERL and PATH environment variables.
define acl_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PERL="$(stage_perl)"
endef

acl_common_config_args := --enable-silent-rules \
                          --enable-shared \
                          --enable-static \
                          --disable-debug

################################################################################
# Staging definitions
################################################################################

acl_stage_config_args := $(acl_common_config_args) \
                         --disable-nls \
                         $(stage_config_flags)

$(call gen_deps,stage-acl,stage-attr)
$(call gen_check_deps,stage-acl,stage-perl)

config_stage-acl       = $(call acl_config_cmds,stage-acl,\
                                                $(stagedir),\
                                                $(acl_stage_config_args))
build_stage-acl        = $(call acl_build_cmds,stage-acl)
clean_stage-acl        = $(call acl_clean_cmds,stage-acl)
install_stage-acl      = $(call acl_install_cmds,stage-acl)
uninstall_stage-acl    = $(call acl_uninstall_cmds,stage-acl,$(stagedir))
check_stage-acl        = $(call acl_check_cmds,stage-acl)

$(call gen_config_rules_with_dep,stage-acl,acl,config_stage-acl)
$(call gen_clobber_rules,stage-acl)
$(call gen_build_rules,stage-acl,build_stage-acl)
$(call gen_clean_rules,stage-acl,clean_stage-acl)
$(call gen_install_rules,stage-acl,install_stage-acl)
$(call gen_uninstall_rules,stage-acl,uninstall_stage-acl)
$(call gen_check_rules,stage-acl,check_stage-acl)
$(call gen_dir_rules,stage-acl)

################################################################################
# Final definitions
#
# Note about the LT_SYS_LIBRARY_PATH setting below:
# ------------------------------------------------
#
# The setting below requests libtool to ignore the specified path
# `$(stagedir)/lib' since it is implicitly added at build / install time.
#
# See section LT_SYS_LIBRARY_PATH section of libtool manual here:
# https://www.gnu.org/software/libtool/manual/html_node/LT_005fINIT.html
################################################################################

acl_final_config_args := $(acl_common_config_args) \
                         --enable-nls \
                         $(final_config_flags) \
                         LT_SYS_LIBRARY_PATH='$(stagedir)/lib'

$(call gen_deps,final-acl,stage-attr stage-gettext)
$(call gen_check_deps,final-acl,stage-perl)

config_final-acl       = $(call acl_config_cmds,final-acl,\
                                                $(PREFIX),\
                                                $(acl_final_config_args))
build_final-acl        = $(call acl_build_cmds,final-acl)
clean_final-acl        = $(call acl_clean_cmds,final-acl)
install_final-acl      = $(call acl_install_cmds,final-acl,$(finaldir))
uninstall_final-acl    = $(call acl_uninstall_cmds,final-acl,\
                                                   $(PREFIX),\
                                                   $(finaldir))
check_final-acl        = $(call acl_check_cmds,final-acl)

$(call gen_config_rules_with_dep,final-acl,acl,config_final-acl)
$(call gen_clobber_rules,final-acl)
$(call gen_build_rules,final-acl,build_final-acl)
$(call gen_clean_rules,final-acl,clean_final-acl)
$(call gen_install_rules,final-acl,install_final-acl)
$(call gen_uninstall_rules,final-acl,uninstall_final-acl)
$(call gen_check_rules,final-acl,check_final-acl)
$(call gen_dir_rules,final-acl)
