################################################################################
# icu4c modules
################################################################################

icu4c_dist_url  := https://github.com/unicode-org/icu4c/releases/download/release-71-1/icu4c-71_1-src.tgz
icu4c_dist_sum  := 1fd2a20aef48369d1f06e2bb74584877b8ad0eb529320b976264ec2db87420bae242715795f372dbc513ea80047bc49077a064e78205cd5e8b33d746fd2a2912
icu4c_vers      := $(subst _,.,$(patsubst icu4c-%-src.tgz,%,\
                                          $(notdir $(icu4c_dist_url))))
icu4c_dist_name := icu4c-$(icu4c_vers).tar.gz
icu4c_brief     := International Components for Unicode
icu4c_home      := https://icu.unicode.org/

define icu4c_desc
ICU is a C++ and C library that provides robust and full-featured Unicode and
locale support.
endef

define fetch_icu4c_dist
$(call download_csum,$(icu4c_dist_url),\
                     $(FETCHDIR)/$(icu4c_dist_name),\
                     $(icu4c_dist_sum))
endef
$(call gen_fetch_rules,icu4c,icu4c_dist_name,fetch_icu4c_dist)

define xtract_icu4c
$(call rmrf,$(srcdir)/icu4c)
$(call untar,$(srcdir)/icu4c,\
             $(FETCHDIR)/$(icu4c_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,icu4c,xtract_icu4c)

$(call gen_dir_rules,icu4c)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define icu4c_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/icu4c/source/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define icu4c_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         $(verbose)
endef

# $(1): targets base name / module name
define icu4c_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define _icu4c_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define icu4c_install_cmds
$(call _icu4c_install_cmds,$(1),$(installdir)/$(strip $(1)))
$(call _icu4c_install_cmds,$(1),$(2))
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define icu4c_uninstall_cmds
$(call uninstall_from_refdir,$(installdir)/$(strip $(1)),$(2))
$(call rmrf,$(installdir)/$(strip $(1)))
endef

# $(1): targets base name / module name
#
# Requires perl to run...
define icu4c_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         LD_LIBRARY_PATH="$(stage_lib_path)"
endef

icu4c_common_config_args := --enable-icu-config \
                            --enable-static \
                            --disable-samples \
                            --disable-rpath

################################################################################
# Staging definitions
################################################################################

icu4c_stage_config_args := $(icu4c_common_config_args) \
                           $(stage_config_flags)

$(call gen_deps,stage-icu4c,stage-pkg-config stage-python)

config_stage-icu4c    = $(call icu4c_config_cmds,stage-icu4c,\
                                                 $(stagedir),\
                                                 $(icu4c_stage_config_args))
build_stage-icu4c     = $(call icu4c_build_cmds,stage-icu4c)
clean_stage-icu4c     = $(call icu4c_clean_cmds,stage-icu4c)
install_stage-icu4c   = $(call icu4c_install_cmds,stage-icu4c)
uninstall_stage-icu4c = $(call icu4c_uninstall_cmds,stage-icu4c,$(stagedir))
check_stage-icu4c     = $(call icu4c_check_cmds,stage-icu4c)

$(call gen_config_rules_with_dep,stage-icu4c,icu4c,config_stage-icu4c)
$(call gen_clobber_rules,stage-icu4c)
$(call gen_build_rules,stage-icu4c,build_stage-icu4c)
$(call gen_clean_rules,stage-icu4c,clean_stage-icu4c)
$(call gen_install_rules,stage-icu4c,install_stage-icu4c)
$(call gen_uninstall_rules,stage-icu4c,uninstall_stage-icu4c)
$(call gen_check_rules,stage-icu4c,check_stage-icu4c)
$(call gen_dir_rules,stage-icu4c)

################################################################################
# Final definitions
################################################################################

icu4c_final_config_args :=  $(icu4c_common_config_args) \
                            $(final_config_flags)

$(call gen_deps,final-icu4c,stage-pkg-config stage-python)

config_final-icu4c    = $(call icu4c_config_cmds,final-icu4c,\
                                                 $(PREFIX),\
                                                 $(icu4c_final_config_args))
build_final-icu4c     = $(call icu4c_build_cmds,final-icu4c)
clean_final-icu4c     = $(call icu4c_clean_cmds,final-icu4c)
install_final-icu4c   = $(call icu4c_install_cmds,final-icu4c,$(finaldir))
uninstall_final-icu4c = $(call icu4c_uninstall_cmds,final-icu4c,$(finaldir))
check_final-icu4c     = $(call icu4c_check_cmds,final-icu4c)

$(call gen_config_rules_with_dep,final-icu4c,icu4c,config_final-icu4c)
$(call gen_clobber_rules,final-icu4c)
$(call gen_build_rules,final-icu4c,build_final-icu4c)
$(call gen_clean_rules,final-icu4c,clean_final-icu4c)
$(call gen_install_rules,final-icu4c,install_final-icu4c)
$(call gen_uninstall_rules,final-icu4c,uninstall_final-icu4c)
$(call gen_check_rules,final-icu4c,check_final-icu4c)
$(call gen_dir_rules,final-icu4c)
