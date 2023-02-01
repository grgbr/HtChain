bdw-gc_dist_url  := https://www.hboehm.info/gc/gc_source/gc-8.2.2.tar.gz
bdw-gc_dist_name := $(notdir bdw-$(bdw-gc_dist_url))

define fetch_bdw-gc_dist
$(call download,$(bdw-gc_dist_url),$(FETCHDIR)/$(bdw-gc_dist_name))
endef
$(call gen_fetch_rules,bdw-gc,bdw-gc_dist_name,fetch_bdw-gc_dist)

define xtract_bdw-gc
$(call rmrf,$(srcdir)/bdw-gc)
$(call untar,$(srcdir)/bdw-gc,\
             $(FETCHDIR)/$(bdw-gc_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,bdw-gc,xtract_bdw-gc)

$(call gen_dir_rules,bdw-gc)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define bdw-gc_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/bdw-gc/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define bdw-gc_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define bdw-gc_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define bdw-gc_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define bdw-gc_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define bdw-gc_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

bdw-gc_common_config_args := --enable-silent-rules \
                             --enable-shared \
                             --enable-static \
                             --enable-threads \
                             --enable-cplusplus \
                             --disable-gcj-support \
                             --disable-java-finalization \
                             --enable-mmap \
                             --enable-handle-fork=auto

################################################################################
# Staging definitions
################################################################################

bdw-gc_stage_config_args := $(bdw-gc_common_args) \
                            --disable-docs \
                            MISSING='true' \
                            $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-bdw-gc,stage-gcc)

config_stage-bdw-gc       = $(call bdw-gc_config_cmds,\
                                   stage-bdw-gc,\
                                   $(stagedir),\
                                   $(bdw-gc_stage_config_args))
build_stage-bdw-gc        = $(call bdw-gc_build_cmds,stage-bdw-gc)
clean_stage-bdw-gc        = $(call bdw-gc_clean_cmds,stage-bdw-gc)
install_stage-bdw-gc      = $(call bdw-gc_install_cmds,stage-bdw-gc)
uninstall_stage-bdw-gc    = $(call bdw-gc_uninstall_cmds,stage-bdw-gc,\
                                                         $(stagedir))
check_stage-bdw-gc        = $(call bdw-gc_check_cmds,stage-bdw-gc)

$(call gen_config_rules_with_dep,stage-bdw-gc,bdw-gc,config_stage-bdw-gc)
$(call gen_clobber_rules,stage-bdw-gc)
$(call gen_build_rules,stage-bdw-gc,build_stage-bdw-gc)
$(call gen_clean_rules,stage-bdw-gc,clean_stage-bdw-gc)
$(call gen_install_rules,stage-bdw-gc,install_stage-bdw-gc)
$(call gen_uninstall_rules,stage-bdw-gc,uninstall_stage-bdw-gc)
$(call gen_check_rules,stage-bdw-gc,check_stage-bdw-gc)
$(call gen_dir_rules,stage-bdw-gc)

################################################################################
# Final definitions
################################################################################

bdw-gc_final_config_args := $(bdw-gc_common_args) \
                            --enable-docs \
                            $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-bdw-gc,stage-gcc)

config_final-bdw-gc       = $(call bdw-gc_config_cmds,\
                                   final-bdw-gc,\
                                   $(PREFIX),\
                                   $(bdw-gc_final_config_args))
build_final-bdw-gc        = $(call bdw-gc_build_cmds,final-bdw-gc)
clean_final-bdw-gc        = $(call bdw-gc_clean_cmds,final-bdw-gc)
install_final-bdw-gc      = $(call bdw-gc_install_cmds,final-bdw-gc,$(finaldir))
uninstall_final-bdw-gc    = $(call bdw-gc_uninstall_cmds,final-bdw-gc,\
                                                         $(PREFIX),\
                                                         $(finaldir))
check_final-bdw-gc        = $(call bdw-gc_check_cmds,final-bdw-gc)

$(call gen_config_rules_with_dep,final-bdw-gc,bdw-gc,config_final-bdw-gc)
$(call gen_clobber_rules,final-bdw-gc)
$(call gen_build_rules,final-bdw-gc,build_final-bdw-gc)
$(call gen_clean_rules,final-bdw-gc,clean_final-bdw-gc)
$(call gen_install_rules,final-bdw-gc,install_final-bdw-gc)
$(call gen_uninstall_rules,final-bdw-gc,uninstall_final-bdw-gc)
$(call gen_check_rules,final-bdw-gc,check_final-bdw-gc)
$(call gen_dir_rules,final-bdw-gc)
