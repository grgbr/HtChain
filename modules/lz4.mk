################################################################################
# lz4 modules
################################################################################

lz4_dist_url  := https://github.com/lz4/lz4/archive/refs/tags/v1.9.3.tar.gz
lz4_dist_sum  := c246b0bda881ee9399fa1be490fa39f43b291bb1d9db72dba8a85db1a50aad416a97e9b300eee3d2a4203c2bd88bda2762e81bc229c3aa409ad217eb306a454c
lz4_vers      := $(patsubst v%.tar.gz,%,$(notdir $(lz4_dist_url)))
lz4_dist_name := lz4-$(lz4_vers).tar.gz
lz4_brief     := Fast LZ compression algorithm library
lz4_home      := https://github.com/lz4/

define lz4_desc
LZ4 is a very fast lossless compression algorithm, providing compression speed
at 400 MB/s per core, scalable with multi-cores CPU. It also features an
extremely fast decoder, with speed in multiple GB/s per core, typically reaching
RAM speed limits on multi-core systems.
endef

define fetch_lz4_dist
$(call download_csum,$(lz4_dist_url),\
                     $(FETCHDIR)/$(lz4_dist_name),\
                     $(lz4_dist_sum))
endef
$(call gen_fetch_rules,lz4,lz4_dist_name,fetch_lz4_dist)

define xtract_lz4
$(call rmrf,$(srcdir)/lz4)
$(call untar,$(srcdir)/lz4,\
             $(FETCHDIR)/$(lz4_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,lz4,xtract_lz4)

$(call gen_dir_rules,lz4)

# $(1): targets base name / module name
define lz4_config_cmds
$(RSYNC) --archive --delete $(srcdir)/lz4/ $(builddir)/$(strip $(1))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define lz4_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         allmost \
         PREFIX='$(strip $(2))' \
         $(3)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define lz4_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean PREFIX='$(strip $(2))' $(3)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
# $(4): optional install destination directory
define lz4_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         PREFIX='$(strip $(2))' \
         $(3) \
         $(if $(strip $(4)),DESTDIR='$(strip $(4))')
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
# $(4): optional install destination directory
define lz4_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          PREFIX='$(strip $(2))' \
          $(3) \
          $(if $(strip $(4)),DESTDIR='$(strip $(4))')
$(call cleanup_empty_dirs,$(strip $(4))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define lz4_check_cmds
+env LD_LIBRARY_PATH='$(builddir)/$(strip $(1))/lib' \
$(MAKE) -j1 \
        --directory $(builddir)/$(strip $(1)) \
        check \
        PREFIX='$(strip $(2))' \
        $(3)
endef

################################################################################
# Bootstrapping definitions
################################################################################

lz4_bstrap_make_args := \
	AR='$(bstrap_ar)' \
	NM='$(bstrap_nm)' \
	RANLIB='$(bstrap_ranlib)' \
	CC='$(bstrap_cc)' \
	CXX='$(bstrap_cxx)' \
	STRIP='$(bstrap_strip)' \
	CPPFLAGS='$(bstrap_cppflags) -I../lib -DXXH_NAMESPACE=LZ4_' \
	CFLAGS='$(call xclude_flags,$(o_flags),$(bstrap_cflags)) -O3' \
	CXXFLAGS='$(call xclude_flags,$(o_flags),$(bstrap_cxxflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags),$(bstrap_ldflags)) -O3' \
	BUILD_SHARED=no

$(call gen_deps,bstrap-lz4,bstrap-gcc)

config_bstrap-lz4    = $(call lz4_config_cmds,bstrap-lz4)
build_bstrap-lz4     = $(call lz4_build_cmds,bstrap-lz4,\
                                             $(bstrapdir),\
                                             $(lz4_bstrap_make_args))
clean_bstrap-lz4     = $(call lz4_clean_cmds,bstrap-lz4,\
                                             $(bstrapdir),\
                                             $(lz4_bstrap_make_args))
install_bstrap-lz4   = $(call lz4_install_cmds,bstrap-lz4,\
                                               $(bstrapdir),\
                                               $(lz4_bstrap_make_args))
uninstall_bstrap-lz4 = $(call lz4_uninstall_cmds,bstrap-lz4,\
                                                 $(bstrapdir),\
                                                 $(lz4_bstrap_make_args))
check_bstrap-lz4     = $(call lz4_check_cmds,bstrap-lz4,\
                                             $(bstrapdir),\
                                             $(lz4_bstrap_make_args))

$(call gen_config_rules_with_dep,bstrap-lz4,lz4,config_bstrap-lz4)
$(call gen_clobber_rules,bstrap-lz4)
$(call gen_build_rules,bstrap-lz4,build_bstrap-lz4)
$(call gen_clean_rules,bstrap-lz4,clean_bstrap-lz4)
$(call gen_install_rules,bstrap-lz4,install_bstrap-lz4)
$(call gen_uninstall_rules,bstrap-lz4,uninstall_bstrap-lz4)
$(call gen_check_rules,bstrap-lz4,check_bstrap-lz4)
$(call gen_dir_rules,bstrap-lz4)

################################################################################
# Staging definitions
################################################################################

lz4_stage_make_args := \
	AR='$(stage_ar)' \
	NM='$(stage_nm)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc)' \
	CXX='$(stage_cxx)' \
	STRIP='$(stage_strip)' \
	CPPFLAGS='$(stage_cppflags) -I../lib -DXXH_NAMESPACE=LZ4_' \
	CFLAGS='$(call xclude_flags,$(o_flags),$(stage_cflags)) -O3' \
	CXXFLAGS='$(call xclude_flags,$(o_flags),$(stage_cxxflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags),$(stage_ldflags)) -O3'

$(call gen_deps,stage-lz4,stage-gcc)

config_stage-lz4    = $(call lz4_config_cmds,stage-lz4)
build_stage-lz4     = $(call lz4_build_cmds,stage-lz4,\
                                            $(stagedir),\
                                            $(lz4_stage_make_args))
clean_stage-lz4     = $(call lz4_clean_cmds,stage-lz4,\
                                            $(stagedir),\
                                            $(lz4_stage_make_args))
install_stage-lz4   = $(call lz4_install_cmds,stage-lz4,\
                                              $(stagedir),\
                                              $(lz4_stage_make_args))
uninstall_stage-lz4 = $(call lz4_uninstall_cmds,stage-lz4,\
                                                $(stagedir),\
                                                $(lz4_stage_make_args))
check_stage-lz4     = $(call lz4_check_cmds,stage-lz4,\
                                            $(stagedir),\
                                            $(lz4_stage_make_args))

$(call gen_config_rules_with_dep,stage-lz4,lz4,config_stage-lz4)
$(call gen_clobber_rules,stage-lz4)
$(call gen_build_rules,stage-lz4,build_stage-lz4)
$(call gen_clean_rules,stage-lz4,clean_stage-lz4)
$(call gen_install_rules,stage-lz4,install_stage-lz4)
$(call gen_uninstall_rules,stage-lz4,uninstall_stage-lz4)
$(call gen_check_rules,stage-lz4,check_stage-lz4)
$(call gen_dir_rules,stage-lz4)

################################################################################
# Final definitions
################################################################################

lz4_final_make_args := \
	AR='$(stage_ar)' \
	NM='$(stage_nm)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc)' \
	CXX='$(stage_cxx)' \
	STRIP='$(stage_strip)' \
	CPPFLAGS='$(final_cppflags) -I../lib -DXXH_NAMESPACE=LZ4_' \
	CFLAGS='$(call xclude_flags,$(o_flags),$(final_cflags)) -O3' \
	CXXFLAGS='$(call xclude_flags,$(o_flags),$(final_cxxflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags),$(final_ldflags)) -O3'

$(call gen_deps,final-lz4,stage-gcc)

config_final-lz4    = $(call lz4_config_cmds,final-lz4)
build_final-lz4     = $(call lz4_build_cmds,final-lz4,\
                                            $(PREFIX),\
                                            $(lz4_final_make_args) manuals)
clean_final-lz4     = $(call lz4_clean_cmds,final-lz4,\
                                            $(PREFIX),\
                                            $(lz4_final_make_args))
install_final-lz4   = $(call lz4_install_cmds,final-lz4,\
                                              $(PREFIX),\
                                              $(lz4_final_make_args),\
                                              $(finaldir))
uninstall_final-lz4 = $(call lz4_uninstall_cmds,final-lz4,\
                                                $(PREFIX),\
                                                $(lz4_final_make_args),\
                                                $(finaldir))
check_final-lz4     = $(call lz4_check_cmds,final-lz4,\
                                            $(PREFIX),\
                                            $(lz4_final_make_args))

$(call gen_config_rules_with_dep,final-lz4,lz4,config_final-lz4)
$(call gen_clobber_rules,final-lz4)
$(call gen_build_rules,final-lz4,build_final-lz4)
$(call gen_clean_rules,final-lz4,clean_final-lz4)
$(call gen_install_rules,final-lz4,install_final-lz4)
$(call gen_uninstall_rules,final-lz4,uninstall_final-lz4)
$(call gen_check_rules,final-lz4,check_final-lz4)
$(call gen_dir_rules,final-lz4)
