################################################################################
# libuv modules
################################################################################

libuv_dist_url  := https://dist.libuv.org/dist/v1.44.2/libuv-v1.44.2-dist.tar.gz
libuv_dist_sum  := fef97751922070a7cac081527b919a4d46e483e8d8b41916eda6aa6bb870eeb1acfa4a507447ee8991965329e8c89c51c953120121765cf7e8a816c41f8ed763
libuv_vers      := $(patsubst libuv-v%-dist.tar.gz,%,$(notdir $(libuv_dist_url)))
libuv_dist_name := libuv-$(libuv_vers).tar.gz
libuv_brief     := Asynchronous event notification library
libuv_home      := https://libuv.org/

define libuv_desc
Libuv is the asynchronous library behind Node.js. Very similar to libevent or
libev, it provides the main elements for event driven systems: watching and
waiting for availability in a set of sockets, and some other events like timers
or asynchronous messages. However, libuv also comes with some other extras like:

* files watchers and asynchronous operations
* a portable TCP and UDP API, as well as asynchronous DNS resolution
* processes and threads management, and a portable inter-process communications
  mechanism, with pipes and work queues
* a plugins mechanism for loading libraries dynamically
* interface with external libraries that also need to access the I/O.
endef

define fetch_libuv_dist
$(call download_csum,$(libuv_dist_url),\
                     $(FETCHDIR)/$(libuv_dist_name),\
                     $(libuv_dist_sum))
endef
$(call gen_fetch_rules,libuv,libuv_dist_name,fetch_libuv_dist)

define xtract_libuv
$(call rmrf,$(srcdir)/libuv)
$(call untar,$(srcdir)/libuv,\
             $(FETCHDIR)/$(libuv_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libuv,xtract_libuv)

$(call gen_dir_rules,libuv)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libuv_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libuv/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libuv_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define libuv_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libuv_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libuv_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define libuv_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

libuv_common_config_args := --enable-silent-rules \
                            --enable-shared \
                            --enable-static

################################################################################
# Staging definitions
################################################################################

libuv_stage_config_args := $(libuv_common_config_args) \
                           MISSING='true' \
                           $(call stage_config_flags,$(rpath_flags))

$(call gen_deps,stage-libuv,stage-gcc)

config_stage-libuv       = $(call libuv_config_cmds,stage-libuv,\
                                                    $(stagedir),\
                                                    $(libuv_stage_config_args))
build_stage-libuv        = $(call libuv_build_cmds,stage-libuv)
clean_stage-libuv        = $(call libuv_clean_cmds,stage-libuv)
install_stage-libuv      = $(call libuv_install_cmds,stage-libuv)
uninstall_stage-libuv    = $(call libuv_uninstall_cmds,stage-libuv,$(stagedir))
check_stage-libuv        = $(call libuv_check_cmds,stage-libuv)

$(call gen_config_rules_with_dep,stage-libuv,libuv,config_stage-libuv)
$(call gen_clobber_rules,stage-libuv)
$(call gen_build_rules,stage-libuv,build_stage-libuv)
$(call gen_clean_rules,stage-libuv,clean_stage-libuv)
$(call gen_install_rules,stage-libuv,install_stage-libuv)
$(call gen_uninstall_rules,stage-libuv,uninstall_stage-libuv)
$(call gen_check_rules,stage-libuv,check_stage-libuv)
$(call gen_dir_rules,stage-libuv)

################################################################################
# Final definitions
################################################################################

libuv_final_config_args := $(libuv_common_config_args) \
                           $(call final_config_flags,$(rpath_flags))

$(call gen_deps,final-libuv,stage-gcc)

config_final-libuv       = $(call libuv_config_cmds,final-libuv,\
                                                    $(PREFIX),\
                                                    $(libuv_final_config_args))
build_final-libuv        = $(call libuv_build_cmds,final-libuv)
clean_final-libuv        = $(call libuv_clean_cmds,final-libuv)
install_final-libuv      = $(call libuv_install_cmds,final-libuv,$(finaldir))
uninstall_final-libuv    = $(call libuv_uninstall_cmds,final-libuv,\
                                                 $(PREFIX),\
                                                 $(finaldir))
check_final-libuv        = $(call libuv_check_cmds,final-libuv)

$(call gen_config_rules_with_dep,final-libuv,libuv,config_final-libuv)
$(call gen_clobber_rules,final-libuv)
$(call gen_build_rules,final-libuv,build_final-libuv)
$(call gen_clean_rules,final-libuv,clean_final-libuv)
$(call gen_install_rules,final-libuv,install_final-libuv)
$(call gen_uninstall_rules,final-libuv,uninstall_final-libuv)
$(call gen_check_rules,final-libuv,check_final-libuv)
$(call gen_dir_rules,final-libuv)
