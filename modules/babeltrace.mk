################################################################################
# babeltrace modules
################################################################################

babeltrace_dist_url  := https://www.efficios.com/files/babeltrace/babeltrace-1.5.11.tar.bz2
babeltrace_dist_sum  := a3158bb9d0306c1cab6ac3d16ba542605ad60b13ecb10fe740a3b95168f0ead87d31483a06d49a15341f7ef6def16765d9a6045f40a60cd8b94070d979c0c3d1
babeltrace_dist_name := $(notdir $(babeltrace_dist_url))
babeltrace_vers      := $(patsubst babeltrace-%.tar.bz2,%,$(babeltrace_dist_name))
babeltrace_brief     := Babeltrace1 trace manipulation toolkit
babeltrace_home      := https://www.efficios.com/babeltrace

define babeltrace_desc
Babeltrace1 provides trace reading and writing libraries, as well as a trace
converter. Plugins can be created for any trace format to allow its conversion
to/from any other supported format.
endef

define fetch_babeltrace_dist
$(call download_csum,$(babeltrace_dist_url),\
                     $(FETCHDIR)/$(babeltrace_dist_name),\
                     $(babeltrace_dist_sum))
endef
$(call gen_fetch_rules,babeltrace,babeltrace_dist_name,fetch_babeltrace_dist)

define xtract_babeltrace
$(call rmrf,$(srcdir)/babeltrace)
$(call untar,$(srcdir)/babeltrace,\
             $(FETCHDIR)/$(babeltrace_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,babeltrace,xtract_babeltrace)

$(call gen_dir_rules,babeltrace)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define babeltrace_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/babeltrace/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define babeltrace_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         $(verbose)
endef

# $(1): targets base name / module name
define babeltrace_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
	clean \
	$(verbose)
endef

# $(1): targets base name / module name
# $(2): build /install prefix
# $(3): optional install destination directory
define babeltrace_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define babeltrace_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define babeltrace_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

babeltrace_common_config_args := --enable-silent-rules \
                                 --enable-shared \
                                 --enable-static \
                                 --enable-debug-info

################################################################################
# Staging definitions
################################################################################

babeltrace_stage_config_args := $(babeltrace_common_config_args) \
                                MISSING='true' \
                                $(stage_config_flags)

$(call gen_deps,stage-babeltrace,stage-glib stage-flex stage-popt)

config_stage-babeltrace       = $(call babeltrace_config_cmds,\
                                       stage-babeltrace,\
                                       $(stagedir),\
                                       $(babeltrace_stage_config_args))
build_stage-babeltrace        = $(call babeltrace_build_cmds,stage-babeltrace)
clean_stage-babeltrace        = $(call babeltrace_clean_cmds,stage-babeltrace)
install_stage-babeltrace      = $(call babeltrace_install_cmds,\
                                       stage-babeltrace,\
                                       $(stagedir))
uninstall_stage-babeltrace    = $(call babeltrace_uninstall_cmds,\
                                       stage-babeltrace,$(stagedir))
check_stage-babeltrace        = $(call babeltrace_check_cmds,stage-babeltrace)

$(call gen_config_rules_with_dep,stage-babeltrace,babeltrace,\
                                                  config_stage-babeltrace)
$(call gen_clobber_rules,stage-babeltrace)
$(call gen_build_rules,stage-babeltrace,build_stage-babeltrace)
$(call gen_clean_rules,stage-babeltrace,clean_stage-babeltrace)
$(call gen_install_rules,stage-babeltrace,install_stage-babeltrace)
$(call gen_uninstall_rules,stage-babeltrace,uninstall_stage-babeltrace)
$(call gen_check_rules,stage-babeltrace,check_stage-babeltrace)
$(call gen_dir_rules,stage-babeltrace)

################################################################################
# Final definitions
################################################################################

# Disable glibtest since may fail because of an existing system-wide development
# glib install conflicting with the one into stagedir. The right glib is
# selected anyway thanks to $(final_config_flags).
# Bypass elfutils version check (bt_cv_lib_elfutils).
babeltrace_final_config_args := $(babeltrace_common_config_args) \
                                --disable-glibtest \
                                bt_cv_lib_elfutils=yes \
                                $(final_config_flags)

$(call gen_deps,final-babeltrace,stage-glib stage-flex stage-popt)

config_final-babeltrace       = $(call babeltrace_config_cmds,\
                                       final-babeltrace,\
                                       $(PREFIX),\
                                       $(babeltrace_final_config_args))
build_final-babeltrace        = $(call babeltrace_build_cmds,final-babeltrace)
clean_final-babeltrace        = $(call babeltrace_clean_cmds,final-babeltrace)
install_final-babeltrace      = $(call babeltrace_install_cmds,\
                                       final-babeltrace,\
                                       $(PREFIX),\
                                       $(finaldir))
uninstall_final-babeltrace    = $(call babeltrace_uninstall_cmds,\
                                       final-babeltrace,\
                                       $(PREFIX),\
                                       $(finaldir))
check_final-babeltrace        = $(call babeltrace_check_cmds,final-babeltrace)

$(call gen_config_rules_with_dep,final-babeltrace,babeltrace,\
                                                  config_final-babeltrace)
$(call gen_clobber_rules,final-babeltrace)
$(call gen_build_rules,final-babeltrace,build_final-babeltrace)
$(call gen_clean_rules,final-babeltrace,clean_final-babeltrace)
$(call gen_install_rules,final-babeltrace,install_final-babeltrace)
$(call gen_uninstall_rules,final-babeltrace,uninstall_final-babeltrace)
$(call gen_check_rules,final-babeltrace,check_final-babeltrace)
$(call gen_dir_rules,final-babeltrace)
