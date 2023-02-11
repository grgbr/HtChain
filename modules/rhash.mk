################################################################################
# rhash modules
################################################################################

rhash_vers      := 1.4.2
rhash_dist_url  := https://sourceforge.net/projects/rhash/files/rhash/$(rhash_vers)/rhash-$(rhash_vers)-src.tar.gz/download
rhash_dist_sum  := 41df57e8b3f32c93d8e6f2ac668b32aaa23eb2eaf90a83f109e61e511404a5036ea88bcf2854e19c1ade0f61960e0d9edf01f3d82e1c645fed36579e9d7a6a25
rhash_dist_name := rhash-$(rhash_vers).tar.gz
rhash_brief     := Library for hash functions computing
rhash_home      := http://rhash.sourceforge.net

define rhash_desc
LibRHash is a professional, portable, thread-safe C library for computing magnet
links and a wide variety of hash sums, such as CRC32, MD4, MD5, SHA1, SHA256,
SHA512, AICH, ED2K, Tiger, DC++ TTH, BitTorrent BTIH, GOST R 34.11-94,
RIPEMD-160, HAS-160, EDON-R, Whirlpool and Snefru.  Hash sums are used to ensure
and verify integrity of large volumes of data for a long-term storing or
transferring.
endef

define fetch_rhash_dist
$(call download_csum,$(rhash_dist_url),\
                     $(FETCHDIR)/$(rhash_dist_name),\
                     $(rhash_dist_sum))
endef
$(call gen_fetch_rules,rhash,rhash_dist_name,fetch_rhash_dist)

define xtract_rhash
$(call rmrf,$(srcdir)/rhash)
$(call untar,$(srcdir)/rhash,\
             $(FETCHDIR)/$(rhash_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,rhash,xtract_rhash)

$(call gen_dir_rules,rhash)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure environment variables
# $(4): configure arguments
define rhash_config_cmds
$(RSYNC) --archive --delete $(srcdir)/rhash/ $(builddir)/$(strip $(1))
cd $(builddir)/$(strip $(1)) && \
env $(3) \
$(srcdir)/rhash/configure --prefix='$(strip $(2))' $(4) $(verbose)
endef

# $(1): targets base name / module name
define rhash_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define rhash_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define rhash_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install install-pkg-config \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(call slink,librhash.so.0,$(strip $(3))$(strip $(2))/lib/librhash.so)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define rhash_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call rmf,$(strip $(3))$(strip $(2))/etc/rhashrc)
$(call rmf,$(strip $(3))$(strip $(2))/lib/librhash.so)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define rhash_check_cmds
+env LD_LIBRARY_PATH="$(stage_lib_path)" \
 $(MAKE) --directory $(builddir)/$(strip $(1)) test
endef

rhash_common_config_args := --enable-openssl=runtime \
                            --enable-lib-static \
                            --enable-lib-shared \
                            --enable-symlinks

################################################################################
# Staging definitions
################################################################################

rhash_stage_config_args := $(rhash_common_config_args) \
                           --cc="$(stage_cc)" \
                           --ar="$(stage_ar)" \
                           --extra-cflags="$(stage_cflags)" \
                           --extra-ldflags="$(stage_ldflags)" \
                           --disable-gettext

$(call gen_deps,stage-rhash,stage-openssl)

config_stage-rhash       = $(call rhash_config_cmds,\
                                  stage-rhash,\
                                  $(stagedir),,\
                                  $(rhash_stage_config_args))
build_stage-rhash        = $(call rhash_build_cmds,stage-rhash)
clean_stage-rhash        = $(call rhash_clean_cmds,stage-rhash)
install_stage-rhash      = $(call rhash_install_cmds,stage-rhash,$(stagedir))
uninstall_stage-rhash    = $(call rhash_uninstall_cmds,stage-rhash,$(stagedir))
check_stage-rhash        = $(call rhash_check_cmds,stage-rhash)

$(call gen_config_rules_with_dep,stage-rhash,rhash,config_stage-rhash)
$(call gen_clobber_rules,stage-rhash)
$(call gen_build_rules,stage-rhash,build_stage-rhash)
$(call gen_clean_rules,stage-rhash,clean_stage-rhash)
$(call gen_install_rules,stage-rhash,install_stage-rhash)
$(call gen_uninstall_rules,stage-rhash,uninstall_stage-rhash)
$(call gen_check_rules,stage-rhash,check_stage-rhash)
$(call gen_dir_rules,stage-rhash)

################################################################################
# Final definitions
################################################################################

rhash_final_config_args := $(rhash_common_config_args) \
                           --enable-gettext \
                           --cc="$(stage_cc)" \
                           --ar="$(stage_ar)" \
                           --extra-cflags="$(final_cflags)" \
                           --extra-ldflags="$(final_ldflags)"

$(call gen_deps,final-rhash,stage-gettext stage-openssl)

config_final-rhash       = $(call rhash_config_cmds,\
                                  final-rhash,\
                                  $(PREFIX),,\
                                  $(rhash_final_config_args))
build_final-rhash        = $(call rhash_build_cmds,final-rhash)
clean_final-rhash        = $(call rhash_clean_cmds,final-rhash)
install_final-rhash      = $(call rhash_install_cmds,final-rhash,\
                                                     $(PREFIX),\
                                                     $(finaldir))
uninstall_final-rhash    = $(call rhash_uninstall_cmds,final-rhash,\
                                                       $(PREFIX),\
                                                       $(finaldir))
check_final-rhash        = $(call rhash_check_cmds,final-rhash)

$(call gen_config_rules_with_dep,final-rhash,rhash,config_final-rhash)
$(call gen_clobber_rules,final-rhash)
$(call gen_build_rules,final-rhash,build_final-rhash)
$(call gen_clean_rules,final-rhash,clean_final-rhash)
$(call gen_install_rules,final-rhash,install_final-rhash)
$(call gen_uninstall_rules,final-rhash,uninstall_final-rhash)
$(call gen_check_rules,final-rhash,check_final-rhash)
$(call gen_dir_rules,final-rhash)
