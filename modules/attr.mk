################################################################################
# attr modules
################################################################################

attr_dist_url  := http://download.savannah.nongnu.org/releases/attr/attr-2.5.1.tar.xz
attr_sig_url   := $(attr_dist_url).sig
attr_dist_name := $(notdir $(attr_dist_url))

define fetch_attr_dist
$(call download_verify_detach,$(attr_dist_url),\
                              $(attr_sig_url),\
                              $(FETCHDIR)/$(attr_dist_name))
endef
$(call gen_fetch_rules,attr,attr_dist_name,fetch_attr_dist)

define xtract_attr
$(call rmrf,$(srcdir)/attr)
$(call untar,$(srcdir)/attr,\
             $(FETCHDIR)/$(attr_dist_name),\
             --strip-components=1)
cd $(srcdir)/attr && \
patch -p1 < $(PATCHDIR)/attr-2.5.1-000-fix_test_perl_interpreter.patch
endef
$(call gen_xtract_rules,attr,xtract_attr)

$(call gen_dir_rules,attr)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define attr_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/attr/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define attr_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define attr_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define attr_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define attr_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
          $(verbose)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man3/attr_listf.3)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man3/attr_getf.3)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man3/attr_multif.3)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man3/attr_setf.3)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man3/attr_removef.3)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Requires perl to run. Thanks to patch above (see xtract_attr recipe), perl
# will be search from PATH environment variable.
define attr_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH="$(stagedir)/bin:$(PATH)"
endef

attr_common_config_args := --enable-silent-rules \
                           --enable-shared \
                           --enable-static \
                           --disable-debug

################################################################################
# Staging definitions
################################################################################

attr_stage_config_args := $(attr_common_config_args) \
                          --disable-nls \
                          $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-attr,stage-gcc)
$(call gen_check_deps,stage-attr,stage-perl)

config_stage-attr       = $(call attr_config_cmds,stage-attr,\
                                                  $(stagedir),\
                                                  $(attr_stage_config_args))
build_stage-attr        = $(call attr_build_cmds,stage-attr)
clean_stage-attr        = $(call attr_clean_cmds,stage-attr)
install_stage-attr      = $(call attr_install_cmds,stage-attr)
uninstall_stage-attr    = $(call attr_uninstall_cmds,stage-attr,$(stagedir))
check_stage-attr        = $(call attr_check_cmds,stage-attr)

$(call gen_config_rules_with_dep,stage-attr,attr,config_stage-attr)
$(call gen_clobber_rules,stage-attr)
$(call gen_build_rules,stage-attr,build_stage-attr)
$(call gen_clean_rules,stage-attr,clean_stage-attr)
$(call gen_install_rules,stage-attr,install_stage-attr)
$(call gen_uninstall_rules,stage-attr,uninstall_stage-attr)
$(call gen_check_rules,stage-attr,check_stage-attr)
$(call gen_dir_rules,stage-attr)

################################################################################
# Final definitions
################################################################################

attr_final_config_args := $(attr_common_config_args) \
                          --enable-nls \
                          $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-attr,stage-gcc)
$(call gen_check_deps,final-attr,stage-perl)

config_final-attr       = $(call attr_config_cmds,final-attr,\
                                                  $(PREFIX),\
                                                  $(attr_final_config_args))
build_final-attr        = $(call attr_build_cmds,final-attr)
clean_final-attr        = $(call attr_clean_cmds,final-attr)
install_final-attr      = $(call attr_install_cmds,final-attr,$(finaldir))
uninstall_final-attr    = $(call attr_uninstall_cmds,final-attr,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-attr        = $(call attr_check_cmds,final-attr)

$(call gen_config_rules_with_dep,final-attr,attr,config_final-attr)
$(call gen_clobber_rules,final-attr)
$(call gen_build_rules,final-attr,build_final-attr)
$(call gen_clean_rules,final-attr,clean_final-attr)
$(call gen_install_rules,final-attr,install_final-attr)
$(call gen_uninstall_rules,final-attr,uninstall_final-attr)
$(call gen_check_rules,final-attr,check_final-attr)
$(call gen_dir_rules,final-attr)
