################################################################################
# libipt modules
################################################################################

libipt_dist_url  := https://github.com/intel/libipt/archive/refs/tags/v2.0.5.tar.gz
libipt_dist_sum  := 2e7ac2aede84671b15597d9c56dbe077a81357bbf44b6684802592246fb7729b4a5743238ddf02f6ea143b4d29872f581408135f9c1ea1ccc99dab905916d98d
libipt_dist_name := $(patsubst v%,libipt-%,$(notdir $(libipt_dist_url)))
libipt_vers      := $(patsubst libipt-%.tar.gz,%,$(libipt_dist_name))
libipt_brief     := Intel Processor Trace Decoder Library
libipt_home      := https://github.com/intel/libipt

define libipt_desc
Intel\'s reference implementation for decoding Intel PT.

Go to https://software.intel.com/en-us/intel-platform-analysis-library for
sample code that uses the library.
endef

define fetch_libipt_dist
$(call download_csum,$(libipt_dist_url),\
                     $(FETCHDIR)/$(libipt_dist_name),\
                     $(libipt_dist_sum))
endef
$(call gen_fetch_rules,libipt,libipt_dist_name,fetch_libipt_dist)

define xtract_libipt
$(call rmrf,$(srcdir)/libipt)
$(call untar,$(srcdir)/libipt,\
             $(FETCHDIR)/$(libipt_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libipt,xtract_libipt)

$(call gen_dir_rules,libipt)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libipt_config_cmds
+cd $(builddir)/$(strip $(1)) && \
 env PATH="$(stagedir)/bin:$(PATH)" \
 $(stagedir)/bin/cmake -G "Unix Makefiles" $(srcdir)/libipt \
                       -DCMAKE_INSTALL_PREFIX="$(strip $(2))" \
                       $(3) \
                       $(verbose)
endef

# $(1): targets base name / module name
define libipt_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(if $(V),VERBOSE=1) $(verbose)
endef

# $(1): targets base name / module name
define libipt_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean \
         clean \
         $(if $(V),VERBOSE=1) $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libipt_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(if $(V),VERBOSE=1) $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libipt_uninstall_cmds
if [ -f $(builddir)/$(strip $(1))/install_manifest.txt ]; then \
	sed -n \
	    's;^\(.\+\)$$;$(strip $(3))\1;p' \
	    $(builddir)/$(strip $(1))/install_manifest.txt | \
	xargs $(RM); \
fi
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

libipt_common_config_args := -DCMAKE_BUILD_TYPE=Release \
                             -DCMAKE_C_COMPILER='$(stage_cc)' \
                             -DFEATURE_THREADS=ON \
                             -DPEVENT=ON \
                             -DFEATURE_ELF=ON \
                             -DSIDEBAND=ON

################################################################################
# Staging definitions
################################################################################

libipt_stage_config_args := $(libipt_common_config_args) \
                            -DCMAKE_C_FLAGS='$(stage_cflags)'

$(call gen_deps,stage-libipt,stage-cmake)

config_stage-libipt       = $(call libipt_config_cmds,\
                                   stage-libipt,\
                                   $(stagedir),\
                                   $(libipt_stage_config_args))
build_stage-libipt        = $(call libipt_build_cmds,stage-libipt)
clean_stage-libipt        = $(call libipt_clean_cmds,stage-libipt)
install_stage-libipt      = $(call libipt_install_cmds,stage-libipt)
uninstall_stage-libipt    = $(call libipt_uninstall_cmds,\
                                   stage-libipt,\
                                   $(stagedir))

$(call gen_config_rules_with_dep,stage-libipt,libipt,config_stage-libipt)
$(call gen_clobber_rules,stage-libipt)
$(call gen_build_rules,stage-libipt,build_stage-libipt)
$(call gen_clean_rules,stage-libipt,clean_stage-libipt)
$(call gen_install_rules,stage-libipt,install_stage-libipt)
$(call gen_uninstall_rules,stage-libipt,uninstall_stage-libipt)
$(call gen_no_check_rules,stage-libipt)
$(call gen_dir_rules,stage-libipt)

################################################################################
# Final definitions
################################################################################

libipt_final_config_args := $(libipt_common_config_args) \
                            -DCMAKE_C_FLAGS='$(final_cflags)'

$(call gen_deps,final-libipt,stage-cmake)

config_final-libipt       = $(call libipt_config_cmds,\
                                   final-libipt,\
                                   $(PREFIX),\
                                   $(libipt_final_config_args))
build_final-libipt        = $(call libipt_build_cmds,final-libipt)
clean_final-libipt        = $(call libipt_clean_cmds,final-libipt)
install_final-libipt      = $(call libipt_install_cmds,final-libipt,$(finaldir))
uninstall_final-libipt    = $(call libipt_uninstall_cmds,final-libipt,\
                                                         $(PREFIX),\
                                                         $(finaldir))

$(call gen_config_rules_with_dep,final-libipt,libipt,config_final-libipt)
$(call gen_clobber_rules,final-libipt)
$(call gen_build_rules,final-libipt,build_final-libipt)
$(call gen_clean_rules,final-libipt,clean_final-libipt)
$(call gen_install_rules,final-libipt,install_final-libipt)
$(call gen_uninstall_rules,final-libipt,uninstall_final-libipt)
$(call gen_no_check_rules,final-libipt)
$(call gen_dir_rules,final-libipt)
