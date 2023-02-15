################################################################################
# kconfig-frontends modules
#
# TODO:
# * depends on bison L10n
# * depends on m4 ?
# * --disable-nls ? (stage vs final)
################################################################################

kconfig-frontends_dist_url  := https://salsa.debian.org/philou/kconfig-frontends/-/archive/debian/4.11.0.1+dfsg-6/kconfig-frontends-debian-4.11.0.1+dfsg-6.tar.bz2
kconfig-frontends_dist_sum  := 14a1651dea1f1ad0ea46c03f40f00a80a3c4e07e0fe6221230d0bb6512c4a5669f3f11938d34f64247e1fb777fdca17b24c131ca1517f1fb452476362ec426ac
kconfig-frontends_vers      := $(shell echo '$(kconfig-frontends_dist_url)' | \
                                       sed 's/.*-\([0-9.]\+\)+.*/\1/')
kconfig-frontends_dist_name := kconfig-frontends-$(kconfig-frontends_vers).tar.bz2
kconfig-frontends_brief     := Standalone implementation of the Linux Kconfig parser and frontend
kconfig-frontends_home      := https://salsa.debian.org/philou/kconfig-frontends

define kconfig-frontends_desc
Kconfig-frontends provides the ``kconfig`` parser, as well as all the frontends
(dialog, ncurses, Qt and Gtk based) to configure and generate config files and
config headers for various projects.
endef

define fetch_kconfig-frontends_dist
$(call download_csum,$(kconfig-frontends_dist_url),\
                     $(FETCHDIR)/$(kconfig-frontends_dist_name),\
                     $(kconfig-frontends_dist_sum))
endef
$(call gen_fetch_rules,kconfig-frontends,\
                       kconfig-frontends_dist_name,\
                       fetch_kconfig-frontends_dist)

define xtract_kconfig-frontends
$(call rmrf,$(srcdir)/kconfig-frontends)
$(call untar,$(srcdir)/kconfig-frontends,\
             $(FETCHDIR)/$(kconfig-frontends_dist_name),\
             --strip-components=1)
cd $(srcdir)/kconfig-frontends && \
for p in $$(grep -v gtk debian/patches/series); do \
	patch -p1 < debian/patches/$$p; \
done
endef
$(call gen_xtract_rules,kconfig-frontends,xtract_kconfig-frontends)

$(call gen_dir_rules,kconfig-frontends)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define kconfig-frontends_config_cmds
if [ ! -f "$(srcdir)/kconfig-frontends/configure" ]; then \
	cd $(srcdir)/kconfig-frontends && \
	PATH="$(stagedir)/bin:$(PATH)" \
	$(stagedir)/bin/autoreconf --install --force; \
fi
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/kconfig-frontends/configure \
	--prefix='$(strip $(2))' \
	$(3) \
	$(verbose)
endef

# $(1): targets base name / module name
define kconfig-frontends_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define kconfig-frontends_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define kconfig-frontends_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(call fixup_shebang,$(strip $(3))$(strip $(2))/bin/kconfig-diff,\
                     $(strip $(2))/bin/python)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define kconfig-frontends_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define kconfig-frontends_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

kconfig-frontends_common_config_args := \
	--enable-silent-rules \
	--enable-static \
	--enable-shared \
	--enable-frontends='kconfig,conf,mconf,nconf'

################################################################################
# Staging definitions
################################################################################
#
#kconfig-frontends_stage_config_args := \
#	$(kconfig-frontends_common_config_args) \
#	MISSING='true' \
#	$(stage_config_flags)
#
#$(call gen_deps,stage-kconfig-frontends,\
#                stage-pkg-config \
#                stage-libtool \
#                stage-flex \
#                stage-gperf \
#                stage-ncurses \
#                stage-python)
#
#config_stage-kconfig-frontends    = $(call kconfig-frontends_config_cmds,\
#                                           stage-kconfig-frontends,\
#                                           $(stagedir),\
#                                           $(kconfig-frontends_stage_config_args))
#build_stage-kconfig-frontends     = $(call kconfig-frontends_build_cmds,\
#                                           stage-kconfig-frontends)
#clean_stage-kconfig-frontends     = $(call kconfig-frontends_clean_cmds,\
#                                           stage-kconfig-frontends)
#install_stage-kconfig-frontends   = $(call kconfig-frontends_install_cmds,\
#                                           stage-kconfig-frontends,\
#                                           $(stagedir))
#uninstall_stage-kconfig-frontends = $(call kconfig-frontends_uninstall_cmds,\
#                                           stage-kconfig-frontends,\
#                                           $(stagedir))
#check_stage-kconfig-frontends     = $(call kconfig-frontends_check_cmds,\
#                                           stage-kconfig-frontends)
#
#$(call gen_config_rules_with_dep,stage-kconfig-frontends,\
#                                 kconfig-frontends,\
#                                 config_stage-kconfig-frontends)
#$(call gen_clobber_rules,stage-kconfig-frontends)
#$(call gen_build_rules,stage-kconfig-frontends,build_stage-kconfig-frontends)
#$(call gen_clean_rules,stage-kconfig-frontends,clean_stage-kconfig-frontends)
#$(call gen_install_rules,stage-kconfig-frontends,\
#                         install_stage-kconfig-frontends)
#$(call gen_uninstall_rules,stage-kconfig-frontends,\
#                           uninstall_stage-kconfig-frontends)
#$(call gen_check_rules,stage-kconfig-frontends,check_stage-kconfig-frontends)
#$(call gen_dir_rules,stage-kconfig-frontends)

################################################################################
# Final definitions
################################################################################

kconfig-frontends_final_config_args := \
	$(kconfig-frontends_common_config_args) \
	$(final_config_flags)

$(call gen_deps,final-kconfig-frontends,\
                stage-pkg-config \
                stage-libtool \
                stage-flex \
                stage-gperf \
                stage-ncurses)

config_final-kconfig-frontends       = $(call kconfig-frontends_config_cmds,\
                                              final-kconfig-frontends,\
                                              $(PREFIX),\
                                              $(kconfig-frontends_final_config_args))
build_final-kconfig-frontends        = $(call kconfig-frontends_build_cmds,\
                                              final-kconfig-frontends)
clean_final-kconfig-frontends        = $(call kconfig-frontends_clean_cmds,\
                                              final-kconfig-frontends)
install_final-kconfig-frontends      = $(call kconfig-frontends_install_cmds,\
                                              final-kconfig-frontends,\
                                              $(PREFIX),\
                                              $(finaldir))
uninstall_final-kconfig-frontends    = $(call kconfig-frontends_uninstall_cmds,\
                                              final-kconfig-frontends,\
                                              $(PREFIX),\
                                              $(finaldir))
check_final-kconfig-frontends        = $(call kconfig-frontends_check_cmds,\
                                              final-kconfig-frontends)

$(call gen_config_rules_with_dep,final-kconfig-frontends,\
                                 kconfig-frontends,\
                                 config_final-kconfig-frontends)
$(call gen_clobber_rules,final-kconfig-frontends)
$(call gen_build_rules,final-kconfig-frontends,build_final-kconfig-frontends)
$(call gen_clean_rules,final-kconfig-frontends,clean_final-kconfig-frontends)
$(call gen_install_rules,final-kconfig-frontends,install_final-kconfig-frontends)
$(call gen_uninstall_rules,final-kconfig-frontends,\
                           uninstall_final-kconfig-frontends)
$(call gen_check_rules,final-kconfig-frontends,check_final-kconfig-frontends)
$(call gen_dir_rules,final-kconfig-frontends)
