################################################################################
# mpc modules
################################################################################

mpc_dist_url  := https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
mpc_dist_sum  := 3279f813ab37f47fdcc800e4ac5f306417d07f539593ca715876e43e04896e1d5bceccfb288ef2908a3f24b760747d0dbd0392a24b9b341bc3e12082e5c836ee
mpc_dist_name := $(notdir $(mpc_dist_url))
mpc_vers      := $(patsubst mpc-%.tar.gz,%,$(mpc_dist_name))
mpc_brief     := Multiple precision complex floating-point library
mpc_home      := https://www.multiprecision.org/mpc/

define mpc_desc
MPC is a portable library written in C for arbitrary precision arithmetic on
complex numbers providing correct rounding. For the time being, it contains all
arithmetic operations over complex numbers, the exponential and the logarithm
functions, the trigonometric and hyperbolic functions.

Ultimately, it should implement a multiprecision equivalent of the ISO C99
standard.
endef

define fetch_mpc_dist
$(call download_csum,$(mpc_dist_url),\
                     $(FETCHDIR)/$(mpc_dist_name),\
                     $(mpc_dist_sum))
endef
$(call gen_fetch_rules,mpc,mpc_dist_name,fetch_mpc_dist)

define xtract_mpc
$(call rmrf,$(srcdir)/mpc)
$(call untar,$(srcdir)/mpc,\
             $(FETCHDIR)/$(mpc_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,mpc,xtract_mpc)

$(call gen_dir_rules,mpc)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define mpc_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/mpc/configure --prefix='$(strip $(2))' \
                        $(3) \
                        $(verbose)
endef

# $(1): targets base name / module name
define mpc_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define mpc_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define mpc_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define mpc_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define mpc_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

mpc_common_args        := --enable-silent-rules \
                          --enable-static \
                          --with-gnu-ld

################################################################################
# Bootstrapping definitions
################################################################################

mpc_bstrap_config_args := $(mpc_common_args) \
                          --disable-shared \
                          --with-gmp='$(bstrapdir)' \
                          --with-mpfr='$(bstrapdir)' \
                          MISSING='/bin/true' \
                          $(bstrap_config_flags)

$(call gen_deps,bstrap-mpc,bstrap-mpfr)

config_bstrap-mpc    = $(call mpc_config_cmds,bstrap-mpc,\
                                              $(bstrapdir),\
                                              $(mpc_bstrap_config_args))
build_bstrap-mpc     = $(call mpc_build_cmds,bstrap-mpc)
clean_bstrap-mpc     = $(call mpc_clean_cmds,bstrap-mpc)
install_bstrap-mpc   = $(call mpc_install_cmds,bstrap-mpc)
uninstall_bstrap-mpc = $(call mpc_uninstall_cmds,bstrap-mpc,$(bstrapdir))
check_bstrap-mpc     = $(call mpc_check_cmds,bstrap-mpc)

$(call gen_config_rules_with_dep,bstrap-mpc,mpc,config_bstrap-mpc)
$(call gen_clobber_rules,bstrap-mpc)
$(call gen_build_rules,bstrap-mpc,build_bstrap-mpc)
$(call gen_clean_rules,bstrap-mpc,clean_bstrap-mpc)
$(call gen_install_rules,bstrap-mpc,install_bstrap-mpc)
$(call gen_uninstall_rules,bstrap-mpc,uninstall_bstrap-mpc)
$(call gen_check_rules,bstrap-mpc,check_bstrap-mpc)
$(call gen_dir_rules,bstrap-mpc)

################################################################################
# Staging definitions
################################################################################

mpc_stage_config_args := $(mpc_common_args) \
                         --enable-shared \
                         --with-gmp='$(stagedir)' \
                         --with-mpfr='$(stagedir)' \
                         MISSING='/bin/true' \
                         AR='$(bstrap_ar)' \
                         NM='$(bstrap_nm)' \
                         RANLIB='$(bstrap_ranlib)' \
                         OBJCOPY='$(bstrap_objcopy)' \
                         OBJDUMP='$(bstrap_objdump)' \
                         READELF='$(bstrap_readelf)' \
                         STRIP='$(bstrap_strip)' \
                         AS='$(bstrap_as)' \
                         CC='$(bstrap_cc)' \
                         CXX='$(bstrap_cxx)' \
                         CPPFLAGS='$(stage_cppflags)' \
                         CFLAGS='$(stage_cflags)' \
                         CXXFLAGS='$(stage_cxxflags)' \
                         LDFLAGS='$(stage_ldflags)' \
                         LD_LIBRARY_PATH='$(bstrap_lib_path)'

$(call gen_deps,stage-mpc,stage-mpfr)
$(call gen_check_deps,stage-mpc,stage-gcc)

config_stage-mpc    = $(call mpc_config_cmds,stage-mpc,\
                                             $(stagedir),\
                                             $(mpc_stage_config_args))
build_stage-mpc     = $(call mpc_build_cmds,stage-mpc)
clean_stage-mpc     = $(call mpc_clean_cmds,stage-mpc)
install_stage-mpc   = $(call mpc_install_cmds,stage-mpc)
uninstall_stage-mpc = $(call mpc_uninstall_cmds,stage-mpc,$(stagedir))
check_stage-mpc     = $(call mpc_check_cmds,stage-mpc)

$(call gen_config_rules_with_dep,stage-mpc,mpc,config_stage-mpc)
$(call gen_clobber_rules,stage-mpc)
$(call gen_build_rules,stage-mpc,build_stage-mpc)
$(call gen_clean_rules,stage-mpc,clean_stage-mpc)
$(call gen_install_rules,stage-mpc,install_stage-mpc)
$(call gen_uninstall_rules,stage-mpc,uninstall_stage-mpc)
$(call gen_check_rules,stage-mpc,check_stage-mpc)
$(call gen_dir_rules,stage-mpc)

################################################################################
# Final definitions
################################################################################

mpc_final_config_args := $(mpc_common_args) \
                         --enable-shared \
                         --with-gmp="$(stagedir)" \
                         --with-mpfr="$(stagedir)" \
                         $(final_config_flags) \
                         LT_SYS_LIBRARY_PATH="$(stagedir)/lib"

$(call gen_deps,final-mpc,stage-mpfr stage-gmp stage-gcc)

config_final-mpc    = $(call mpc_config_cmds,final-mpc,\
                                             $(PREFIX),\
                                             $(mpc_final_config_args))
build_final-mpc     = $(call mpc_build_cmds,final-mpc)
clean_final-mpc     = $(call mpc_clean_cmds,final-mpc)
install_final-mpc   = $(call mpc_install_cmds,final-mpc,$(finaldir))
uninstall_final-mpc = $(call mpc_uninstall_cmds,final-mpc,\
                                                $(PREFIX),\
                                                $(finaldir))
check_final-mpc     = $(call mpc_check_cmds,final-mpc)

$(call gen_config_rules_with_dep,final-mpc,mpc,config_final-mpc)
$(call gen_clobber_rules,final-mpc)
$(call gen_build_rules,final-mpc,build_final-mpc)
$(call gen_clean_rules,final-mpc,clean_final-mpc)
$(call gen_install_rules,final-mpc,install_final-mpc)
$(call gen_uninstall_rules,final-mpc,uninstall_final-mpc)
$(call gen_check_rules,final-mpc,check_final-mpc)
$(call gen_dir_rules,final-mpc)
