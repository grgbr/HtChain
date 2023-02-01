chrpath_dist_url  := http://deb.debian.org/debian/pool/main/c/chrpath/chrpath_0.16.orig.tar.gz
chrpath_dist_name := $(notdir $(chrpath_dist_url))

define fetch_chrpath_dist
$(call download,$(chrpath_dist_url),$(FETCHDIR)/$(chrpath_dist_name))
endef
$(call gen_fetch_rules,chrpath,chrpath_dist_name,fetch_chrpath_dist)

define xtract_chrpath
$(call rmrf,$(srcdir)/chrpath)
$(call untar,$(srcdir)/chrpath,\
             $(FETCHDIR)/$(chrpath_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,chrpath,xtract_chrpath)

$(call gen_dir_rules,chrpath)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define chrpath_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/chrpath/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define chrpath_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define chrpath_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define chrpath_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define chrpath_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define chrpath_check_cmds
+$(MAKE) -j1 --directory $(builddir)/$(strip $(1)) check
endef

################################################################################
# Staging definitions
################################################################################

chrpath_stage_config_args := MISSING='true' \
                             $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-chrpath,stage-gcc)

config_stage-chrpath       = $(call chrpath_config_cmds,\
                                    stage-chrpath,\
                                    $(stagedir),\
                                    $(chrpath_stage_config_args))
build_stage-chrpath        = $(call chrpath_build_cmds,stage-chrpath)
clean_stage-chrpath        = $(call chrpath_clean_cmds,stage-chrpath)
install_stage-chrpath      = $(call chrpath_install_cmds,stage-chrpath)
uninstall_stage-chrpath    = $(call chrpath_uninstall_cmds,stage-chrpath,\
                                                           $(stagedir))
check_stage-chrpath        = $(call chrpath_check_cmds,stage-chrpath)

$(call gen_config_rules_with_dep,stage-chrpath,chrpath,config_stage-chrpath)
$(call gen_clobber_rules,stage-chrpath)
$(call gen_build_rules,stage-chrpath,build_stage-chrpath)
$(call gen_clean_rules,stage-chrpath,clean_stage-chrpath)
$(call gen_install_rules,stage-chrpath,install_stage-chrpath)
$(call gen_uninstall_rules,stage-chrpath,uninstall_stage-chrpath)
$(call gen_check_rules,stage-chrpath,check_stage-chrpath)
$(call gen_dir_rules,stage-chrpath)

################################################################################
# Final definitions
################################################################################

chrpath_final_config_args := $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-chrpath,stage-gcc)

config_final-chrpath       = $(call chrpath_config_cmds,\
                                    final-chrpath,\
                                    $(PREFIX),\
                                    $(chrpath_final_config_args))
build_final-chrpath        = $(call chrpath_build_cmds,final-chrpath)
clean_final-chrpath        = $(call chrpath_clean_cmds,final-chrpath)
install_final-chrpath      = $(call chrpath_install_cmds,final-chrpath,\
                                                         $(finaldir))
uninstall_final-chrpath    = $(call chrpath_uninstall_cmds,\
                                    final-chrpath \
                                    $(PREFIX),\
                                    $(finaldir))
check_final-chrpath        = $(call chrpath_check_cmds,final-chrpath)

$(call gen_config_rules_with_dep,final-chrpath,chrpath,config_final-chrpath)
$(call gen_clobber_rules,final-chrpath)
$(call gen_build_rules,final-chrpath,build_final-chrpath)
$(call gen_clean_rules,final-chrpath,clean_final-chrpath)
$(call gen_install_rules,final-chrpath,install_final-chrpath)
$(call gen_uninstall_rules,final-chrpath,uninstall_final-chrpath)
$(call gen_check_rules,final-chrpath,check_final-chrpath)
$(call gen_dir_rules,final-chrpath)
