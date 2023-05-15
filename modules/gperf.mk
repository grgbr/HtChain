################################################################################
# gperf modules
################################################################################

gperf_dist_url  := https://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz
gperf_dist_sum  := 855ebce5ff36753238a44f14c95be7afdc3990b085960345ca2caf1a2db884f7db74d406ce9eec2f4a52abb8a063d4ed000a36b317c9a353ef4e25e2cca9a3f4
gperf_dist_name := $(notdir $(gperf_dist_url))
gperf_vers      := $(patsubst gperf-%.tar.gz,%,$(gperf_dist_name))
gperf_brief     := Perfect hash function generator
gperf_home      := http://www.gnu.org/software/gperf/

define gperf_desc
gperf is a program that generates perfect hash functions for sets of key words.

A perfect hash function is simply: a hash function and a data structure that
allows recognition of a key word in a set of words using exactly 1 probe into
the data structure.
endef

define fetch_gperf_dist
$(call download_csum,$(gperf_dist_url),\
                     $(gperf_dist_name),\
                     $(gperf_dist_sum))
endef
$(call gen_fetch_rules,gperf,gperf_dist_name,fetch_gperf_dist)

define xtract_gperf
$(call rmrf,$(srcdir)/gperf)
$(call untar,$(srcdir)/gperf,\
             $(FETCHDIR)/$(gperf_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,gperf,xtract_gperf)

$(call gen_dir_rules,gperf)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gperf_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/gperf/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define gperf_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define gperf_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define gperf_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gperf_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define gperf_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

################################################################################
# Staging definitions
################################################################################

gperf_stage_config_args := --enable-silent-rules \
                           $(stage_config_flags)

$(call gen_deps,stage-gperf,stage-gcc)

config_stage-gperf       = $(call gperf_config_cmds,stage-gperf,\
                                                    $(stagedir),\
                                                    $(gperf_stage_config_args))
build_stage-gperf        = $(call gperf_build_cmds,stage-gperf)
clean_stage-gperf        = $(call gperf_clean_cmds,stage-gperf)
install_stage-gperf      = $(call gperf_install_cmds,stage-gperf)
uninstall_stage-gperf    = $(call gperf_uninstall_cmds,stage-gperf,$(stagedir))
check_stage-gperf        = $(call gperf_check_cmds,stage-gperf)

$(call gen_config_rules_with_dep,stage-gperf,gperf,config_stage-gperf)
$(call gen_clobber_rules,stage-gperf)
$(call gen_build_rules,stage-gperf,build_stage-gperf)
$(call gen_clean_rules,stage-gperf,clean_stage-gperf)
$(call gen_install_rules,stage-gperf,install_stage-gperf)
$(call gen_uninstall_rules,stage-gperf,uninstall_stage-gperf)
$(call gen_check_rules,stage-gperf,check_stage-gperf)
$(call gen_dir_rules,stage-gperf)

################################################################################
# Final definitions
################################################################################

gperf_final_config_args := --enable-silent-rules \
                           $(final_config_flags)

$(call gen_deps,final-gperf,stage-gcc)

config_final-gperf       = $(call gperf_config_cmds,final-gperf,\
                                                    $(PREFIX),\
                                                    $(gperf_final_config_args))
build_final-gperf        = $(call gperf_build_cmds,final-gperf)
clean_final-gperf        = $(call gperf_clean_cmds,final-gperf)
install_final-gperf      = $(call gperf_install_cmds,final-gperf,$(finaldir))
uninstall_final-gperf    = $(call gperf_uninstall_cmds,final-gperf,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-gperf        = $(call gperf_check_cmds,final-gperf)

$(call gen_config_rules_with_dep,final-gperf,gperf,config_final-gperf)
$(call gen_clobber_rules,final-gperf)
$(call gen_build_rules,final-gperf,build_final-gperf)
$(call gen_clean_rules,final-gperf,clean_final-gperf)
$(call gen_install_rules,final-gperf,install_final-gperf)
$(call gen_uninstall_rules,final-gperf,uninstall_final-gperf)
$(call gen_check_rules,final-gperf,check_final-gperf)
$(call gen_dir_rules,final-gperf)
