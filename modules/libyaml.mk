################################################################################
# libyaml modules
################################################################################

libyaml_dist_url  := https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz
libyaml_dist_name := lib$(notdir $(libyaml_dist_url))

define fetch_libyaml_dist
$(call download,$(libyaml_dist_url),$(FETCHDIR)/$(libyaml_dist_name))
endef
$(call gen_fetch_rules,libyaml,libyaml_dist_name,fetch_libyaml_dist)

define xtract_libyaml
$(call rmrf,$(srcdir)/libyaml)
$(call untar,$(srcdir)/libyaml,\
             $(FETCHDIR)/$(libyaml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libyaml,xtract_libyaml)

$(call gen_dir_rules,libyaml)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libyaml_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libyaml/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libyaml_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define libyaml_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libyaml_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libyaml_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# PATH required to find dejaGNU `runtest' tool.
define libyaml_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH="$(stagedir)/bin:$(PATH)"
endef

libyaml_common_config_args := \
	--enable-silent-rules \
	--enable-shared \
	--enable-static

################################################################################
# Staging definitions
################################################################################

libyaml_stage_config_args := $(libyaml_common_config_args) \
                             --with-sysroot='$(stagedir)' \
                             MAKEINFO=true \
                             $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-libyaml,stage-gcc)

config_stage-libyaml    = $(call libyaml_config_cmds,stage-libyaml,\
                                                     $(stagedir),\
                                                     $(libyaml_stage_config_args))
build_stage-libyaml     = $(call libyaml_build_cmds,stage-libyaml)
clean_stage-libyaml     = $(call libyaml_clean_cmds,stage-libyaml)
install_stage-libyaml   = $(call libyaml_install_cmds,stage-libyaml,$(stagedir))
uninstall_stage-libyaml = $(call libyaml_uninstall_cmds,stage-libyaml,$(stagedir))
check_stage-libyaml     = $(call libyaml_check_cmds,stage-libyaml)

$(call gen_config_rules_with_dep,stage-libyaml,libyaml,config_stage-libyaml)
$(call gen_clobber_rules,stage-libyaml)
$(call gen_build_rules,stage-libyaml,build_stage-libyaml)
$(call gen_clean_rules,stage-libyaml,clean_stage-libyaml)
$(call gen_install_rules,stage-libyaml,install_stage-libyaml)
$(call gen_uninstall_rules,stage-libyaml,uninstall_stage-libyaml)
$(call gen_check_rules,stage-libyaml,check_stage-libyaml)
$(call gen_dir_rules,stage-libyaml)

################################################################################
# Final definitions
################################################################################

libyaml_final_config_args := $(libyaml_common_config_args) \
                             --with-sysroot='$(finaldir)$(PREFIX)' \
                             $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-libyaml,stage-gcc stage-texinfo)

config_final-libyaml    = $(call libyaml_config_cmds,final-libyaml,\
                                                     $(PREFIX),\
                                                     $(libyaml_final_config_args))
build_final-libyaml     = $(call libyaml_build_cmds,final-libyaml)
clean_final-libyaml     = $(call libyaml_clean_cmds,final-libyaml)
install_final-libyaml   = $(call libyaml_install_cmds,final-libyaml,\
                                                    $(PREFIX),\
                                                    $(finaldir))
uninstall_final-libyaml = $(call libyaml_uninstall_cmds,final-libyaml,\
                                                      $(PREFIX),\
                                                      $(finaldir))
check_final-libyaml     = $(call libyaml_check_cmds,final-libyaml)

$(call gen_config_rules_with_dep,final-libyaml,libyaml,config_final-libyaml)
$(call gen_clobber_rules,final-libyaml)
$(call gen_build_rules,final-libyaml,build_final-libyaml)
$(call gen_clean_rules,final-libyaml,clean_final-libyaml)
$(call gen_install_rules,final-libyaml,install_final-libyaml)
$(call gen_uninstall_rules,final-libyaml,uninstall_final-libyaml)
$(call gen_check_rules,final-libyaml,check_final-libyaml)
$(call gen_dir_rules,final-libyaml)
