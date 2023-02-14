################################################################################
# guile modules
################################################################################

guile_dist_url   := https://ftp.gnu.org/gnu/guile/guile-3.0.9.tar.xz
guile_dist_sum   := a1e47a60a654f26edc57b3a34d943e15a055fc85c3cc764e912be23a80d56534b16f3512d7c7bc426f24a0cac1fcc9556802ac248f10c1fbdde51cd1e24afaf2
guile_dist_name  := $(notdir $(guile_dist_url))
guile_vers       := $(patsubst guile-%.tar.xz,%,$(guile_dist_name))
_guile_vers_toks := $(subst .,$(space),$(guile_vers))
guile_vers_maj   := $(word 1,$(_guile_vers_toks))
guile_vers_min   := $(word 2,$(_guile_vers_toks))
guile_brief      := GNU extension language and Scheme interpreter
guile_home       := http://www.gnu.org/software/guile/

define guile_desc
Guile is a Scheme implementation designed for real world programming, providing
a rich Unix interface, a module system, an interpreter, and many extension
languages. Guile can be used as a standard ``#!`` style interpreter, via
``#!/usr/bin/guile``, or as an extension language for other applications via
libguile.
endef

define fetch_guile_dist
$(call download_csum,$(guile_dist_url),\
                     $(FETCHDIR)/$(guile_dist_name),\
                     $(guile_dist_sum))
endef
$(call gen_fetch_rules,guile,guile_dist_name,fetch_guile_dist)

define xtract_guile
$(call rmrf,$(srcdir)/guile)
$(call untar,$(srcdir)/guile,\
             $(FETCHDIR)/$(guile_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,guile,xtract_guile)

$(call gen_dir_rules,guile)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define guile_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/guile/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define guile_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define guile_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define guile_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define guile_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call rmf,$(if $(strip $(3)),$(strip $(3)))$(strip $(2))/bin/guile-tools)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define guile_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

guile_common_config_args := --enable-silent-rules \
                            --enable-lto \
                            --enable-shared \
                            --enable-static \
                            --enable-year2038 \
                            --with-threads

################################################################################
# Staging definitions
################################################################################

guile_stage_config_args := $(guile_common_config_args) \
                           --disable-nls \
                           MISSING='true' \
                           $(stage_config_flags)

$(call gen_deps,stage-guile,stage-bdw-gc \
                            stage-libunistring \
                            stage-readline \
                            stage-gperf \
                            stage-libffi)

config_stage-guile       = $(call guile_config_cmds,stage-guile,\
                                                    $(stagedir),\
                                                    $(guile_stage_config_args))
build_stage-guile        = $(call guile_build_cmds,stage-guile)
clean_stage-guile        = $(call guile_clean_cmds,stage-guile)
install_stage-guile      = $(call guile_install_cmds,stage-guile)
uninstall_stage-guile    = $(call guile_uninstall_cmds,stage-guile,$(stagedir))
check_stage-guile        = $(call guile_check_cmds,stage-guile)

$(call gen_config_rules_with_dep,stage-guile,guile,config_stage-guile)
$(call gen_clobber_rules,stage-guile)
$(call gen_build_rules,stage-guile,build_stage-guile)
$(call gen_clean_rules,stage-guile,clean_stage-guile)
$(call gen_install_rules,stage-guile,install_stage-guile)
$(call gen_uninstall_rules,stage-guile,uninstall_stage-guile)
$(call gen_check_rules,stage-guile,check_stage-guile)
$(call gen_dir_rules,stage-guile)

################################################################################
# Final definitions
################################################################################

guile_final_config_args := \
	$(guile_common_config_args) \
	--enable-nls \
	GUILE_FOR_BUILD='$(stage_guile)' \
	$(final_config_flags)

$(call gen_deps,final-guile,stage-bdw-gc \
                            stage-libunistring \
                            stage-readline \
                            stage-gperf \
                            stage-libffi \
                            stage-gettext \
                            stage-chrpath)

config_final-guile       = $(call guile_config_cmds,final-guile,\
                                                    $(PREFIX),\
                                                    $(guile_final_config_args))
build_final-guile        = $(call guile_build_cmds,final-guile)
clean_final-guile        = $(call guile_clean_cmds,final-guile)

define install_final-guile
$(call guile_install_cmds,final-guile,$(finaldir))
$(stage_chrpath) --replace "$(final_lib_path)" \
                 $(finaldir)$(PREFIX)/lib/libguile-$(guile_vers_maj).$(guile_vers_min).so \
                 $(verbose)
$(stage_chrpath) --replace "$(final_lib_path)" \
                 $(finaldir)$(PREFIX)/bin/guile \
                 $(verbose)
$(stage_chrpath) --replace "$(final_lib_path)" \
                 $(finaldir)$(PREFIX)/lib/guile/$(guile_vers_maj).$(guile_vers_min)/extensions/guile-readline.so \
                 $(verbose)
endef

uninstall_final-guile    = $(call guile_uninstall_cmds,final-guile,\
                                                       $(PREFIX),\
                                                       $(finaldir))
check_final-guile        = $(call guile_check_cmds,final-guile)

$(call gen_config_rules_with_dep,final-guile,guile,config_final-guile)
$(call gen_clobber_rules,final-guile)
$(call gen_build_rules,final-guile,build_final-guile)
$(call gen_clean_rules,final-guile,clean_final-guile)
$(call gen_install_rules,final-guile,install_final-guile)
$(call gen_uninstall_rules,final-guile,uninstall_final-guile)
$(call gen_check_rules,final-guile,check_final-guile)
$(call gen_dir_rules,final-guile)
