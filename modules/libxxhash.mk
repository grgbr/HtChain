################################################################################
# libxxhash modules
################################################################################

libxxhash_dist_url  := https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.1.tar.gz
libxxhash_dist_sum  := 12feedd6a1859ef55e27218dbd6dcceccbb5a4da34cd80240d2f7d44cd246c7afdeb59830c2d5b90189bb5159293532208bf5bb622250102e12d6e1bad14a193
libxxhash_dist_name := libxxhash-$(patsubst v%,%,$(notdir $(libxxhash_dist_url)))
libxxhash_vers      := $(patsubst libxxhash-%.tar.gz,%,$(libxxhash_dist_name))
libxxhash_brief     := xxHash, a fast non-cryptographic hash algorithm
libxxhash_home      := https://github.com/Cyan4973/xxHash

define libxxhash_desc
xxHash is an Extremely fast Hash algorithm, running at RAM speed limits. It
successfully completes the SMHasher test suite which evaluates collision,
dispersion and randomness qualities of hash functions. Code is highly portable,
and hashes are identical on all platforms (little / big endian).
endef

define fetch_libxxhash_dist
$(call download_csum,$(libxxhash_dist_url),\
                     $(libxxhash_dist_name),\
                     $(libxxhash_dist_sum))
endef
$(call gen_fetch_rules,libxxhash,libxxhash_dist_name,fetch_libxxhash_dist)

define xtract_libxxhash
$(call rmrf,$(srcdir)/libxxhash)
$(call untar,$(srcdir)/libxxhash,\
             $(FETCHDIR)/$(libxxhash_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libxxhash,xtract_libxxhash)

$(call gen_dir_rules,libxxhash)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libxxhash_config_cmds
$(RSYNC) --archive --delete $(srcdir)/libxxhash/ $(builddir)/$(strip $(1))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define libxxhash_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         default \
         prefix='$(strip $(2))' \
         $(3) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define libxxhash_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         prefix='$(strip $(2))' \
         $(3) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define libxxhash_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         prefix='$(strip $(2))' \
         $(3) \
         $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
# $(4): optional install destination directory
define libxxhash_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          prefix='$(strip $(2))' \
          $(3) \
          $(if $(strip $(4)),DESTDIR='$(strip $(4))') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(4))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): make arguments
define libxxhash_check_cmds
+env LD_LIBRARY_PATH='$(builddir)/$(strip $(1))/lib' \
$(MAKE) --directory $(builddir)/$(strip $(1)) \
        check \
        prefix='$(strip $(2))' \
        $(3)
endef

libxxhash_common_make_args := \
	SONAME_FLAGS='-shared -Wl,-soname=libxxhash.$$(SHARED_EXT).$$(LIBVER_MAJOR)'

################################################################################
# Staging definitions
################################################################################

libxxhash_stage_make_args := \
	$(libxxhash_common_make_args) \
	AR='$(stage_ar)' \
	NM='$(stage_nm)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc)' \
	CXX='$(stage_cxx)' \
	STRIP='$(stage_strip)' \
	CFLAGS='$(call xclude_flags,$(o_flags),$(stage_cflags)) -O3 $$(DEBUGFLAGS) $$(MOREFLAGS)' \
	CPPFLAGS='$(stage_cppflags)' \
	CXXFLAGS='$(call xclude_flags,$(o_flags),$(stage_cxxflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags) $(rpath_flags),$(stage_ldflags)) -O3'

$(call gen_deps,stage-libxxhash,stage-gcc)

config_stage-libxxhash    = $(call libxxhash_config_cmds,stage-libxxhash)
build_stage-libxxhash     = $(call libxxhash_build_cmds,\
                                   stage-libxxhash,\
                                   $(stagedir),\
                                   $(libxxhash_stage_make_args))
clean_stage-libxxhash     = $(call libxxhash_clean_cmds,\
                                   stage-libxxhash,\
                                   $(stagedir),\
                                   $(libxxhash_stage_make_args))
install_stage-libxxhash   = $(call libxxhash_install_cmds,\
                                   stage-libxxhash,\
                                   $(stagedir),\
                                   $(libxxhash_stage_make_args))
uninstall_stage-libxxhash = $(call libxxhash_uninstall_cmds,\
                                   stage-libxxhash,\
                                   $(stagedir),\
                                   $(libxxhash_stage_make_args))
check_stage-libxxhash     = $(call libxxhash_check_cmds,\
                                   stage-libxxhash,\
                                   $(stagedir),\
                                   $(libxxhash_stage_make_args))

$(call gen_config_rules_with_dep,stage-libxxhash,libxxhash,config_stage-libxxhash)
$(call gen_clobber_rules,stage-libxxhash)
$(call gen_build_rules,stage-libxxhash,build_stage-libxxhash)
$(call gen_clean_rules,stage-libxxhash,clean_stage-libxxhash)
$(call gen_install_rules,stage-libxxhash,install_stage-libxxhash)
$(call gen_uninstall_rules,stage-libxxhash,uninstall_stage-libxxhash)
$(call gen_check_rules,stage-libxxhash,check_stage-libxxhash)
$(call gen_dir_rules,stage-libxxhash)

################################################################################
# Final definitions
################################################################################

libxxhash_final_make_args := \
	$(libxxhash_common_make_args) \
	AR='$(stage_ar)' \
	NM='$(stage_nm)' \
	RANLIB='$(stage_ranlib)' \
	CC='$(stage_cc)' \
	CXX='$(stage_cxx)' \
	STRIP='$(stage_strip)' \
	CPPFLAGS='$(final_cppflags)' \
	CFLAGS='$(call xclude_flags,$(o_flags),$(final_cflags)) -O3 $$(DEBUGFLAGS) $$(MOREFLAGS)' \
	CXXFLAGS='$(call xclude_flags,$(o_flags),$(final_cxxflags)) -O3' \
	LDFLAGS='$(call xclude_flags,$(o_flags) $(rpath_flags),$(final_ldflags)) -O3'

$(call gen_deps,final-libxxhash,stage-gcc)

config_final-libxxhash    = $(call libxxhash_config_cmds,final-libxxhash)
build_final-libxxhash     = $(call libxxhash_build_cmds,\
                                   final-libxxhash,\
                                   $(PREFIX),\
                                   $(libxxhash_final_make_args))
clean_final-libxxhash     = $(call libxxhash_clean_cmds,\
                                   final-libxxhash,\
                                   $(PREFIX),\
                                   $(libxxhash_final_make_args))
install_final-libxxhash   = $(call libxxhash_install_cmds,\
                                   final-libxxhash,\
                                   $(PREFIX),\
                                   $(libxxhash_final_make_args),\
                                   $(finaldir))
uninstall_final-libxxhash = $(call libxxhash_uninstall_cmds,\
                                   final-libxxhash,\
                                   $(PREFIX),\
                                   $(libxxhash_final_make_args),\
                                   $(finaldir))
check_final-libxxhash     = $(call libxxhash_check_cmds,\
                                   final-libxxhash,\
                                   $(PREFIX),\
                                   $(libxxhash_final_make_args))

$(call gen_config_rules_with_dep,final-libxxhash,\
                                 libxxhash,config_final-libxxhash)
$(call gen_clobber_rules,final-libxxhash)
$(call gen_build_rules,final-libxxhash,build_final-libxxhash)
$(call gen_clean_rules,final-libxxhash,clean_final-libxxhash)
$(call gen_install_rules,final-libxxhash,install_final-libxxhash)
$(call gen_uninstall_rules,final-libxxhash,uninstall_final-libxxhash)
$(call gen_check_rules,final-libxxhash,check_final-libxxhash)
$(call gen_dir_rules,final-libxxhash)
