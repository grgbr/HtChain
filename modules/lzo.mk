lzo_dist_url  := http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
lzo_dist_sum  := 4924676a9bae5db58ef129dc1cebce3baa3c4b5d
lzo_dist_name := $(notdir $(lzo_dist_url))

define fetch_lzo_dist
$(call _download,$(lzo_dist_url),$(FETCHDIR)/$(lzo_dist_name).tmp)
cat $(FETCHDIR)/$(lzo_dist_name).tmp | \
	sha1sum --check --status <(echo "$(lzo_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(lzo_dist_name).tmp,\
          $(FETCHDIR)/$(lzo_dist_name))
endef
# As fetch_lzo_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(lzo_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,lzo,lzo_dist_name,fetch_lzo_dist)

define xtract_lzo
$(call rmrf,$(srcdir)/lzo)
$(call untar,$(srcdir)/lzo,\
             $(FETCHDIR)/$(lzo_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,lzo,xtract_lzo)

$(call gen_dir_rules,lzo)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define lzo_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/lzo/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define lzo_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define lzo_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define lzo_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define lzo_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define lzo_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) test
endef

lzo_common_config_args := --enable-silent-rules \
                          --enable-static \
                          --enable-shared

################################################################################
# Staging definitions
################################################################################

lzo_stage_config_args := $(lzo_common_config_args) \
                         $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-lzo,stage-gcc)

config_stage-lzo       = $(call lzo_config_cmds,stage-lzo,\
                                                $(stagedir),\
                                                $(lzo_stage_config_args))
build_stage-lzo        = $(call lzo_build_cmds,stage-lzo)
clean_stage-lzo        = $(call lzo_clean_cmds,stage-lzo)
install_stage-lzo      = $(call lzo_install_cmds,stage-lzo)
uninstall_stage-lzo    = $(call lzo_uninstall_cmds,stage-lzo,$(stagedir))
check_stage-lzo        = $(call lzo_check_cmds,stage-lzo)

$(call gen_config_rules_with_dep,stage-lzo,lzo,config_stage-lzo)
$(call gen_clobber_rules,stage-lzo)
$(call gen_build_rules,stage-lzo,build_stage-lzo)
$(call gen_clean_rules,stage-lzo,clean_stage-lzo)
$(call gen_install_rules,stage-lzo,install_stage-lzo)
$(call gen_uninstall_rules,stage-lzo,uninstall_stage-lzo)
$(call gen_check_rules,stage-lzo,check_stage-lzo)
$(call gen_dir_rules,stage-lzo)

################################################################################
# Final definitions
################################################################################

lzo_final_config_args := $(lzo_common_config_args) \
                         $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-lzo,stage-gcc)

config_final-lzo       = $(call lzo_config_cmds,final-lzo,\
                                                $(PREFIX),\
                                                $(lzo_final_config_args))
build_final-lzo        = $(call lzo_build_cmds,final-lzo)
clean_final-lzo        = $(call lzo_clean_cmds,final-lzo)
install_final-lzo      = $(call lzo_install_cmds,final-lzo,$(finaldir))
uninstall_final-lzo    = $(call lzo_uninstall_cmds,final-lzo,\
                                                   $(PREFIX),\
                                                   $(finaldir))
check_final-lzo        = $(call lzo_check_cmds,final-lzo)

$(call gen_config_rules_with_dep,final-lzo,lzo,config_final-lzo)
$(call gen_clobber_rules,final-lzo)
$(call gen_build_rules,final-lzo,build_final-lzo)
$(call gen_clean_rules,final-lzo,clean_final-lzo)
$(call gen_install_rules,final-lzo,install_final-lzo)
$(call gen_uninstall_rules,final-lzo,uninstall_final-lzo)
$(call gen_check_rules,final-lzo,check_final-lzo)
$(call gen_dir_rules,final-lzo)
