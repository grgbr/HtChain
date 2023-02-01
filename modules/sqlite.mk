################################################################################
# sqlite modules
################################################################################

sqlite_dist_url   := https://github.com/sqlite/sqlite/archive/refs/tags/version-3.39.0.tar.gz
sqlite_dist_name  := $(patsubst version-%,sqlite-%,$(notdir $(sqlite_dist_url)))
sqlite_vers       := $(shell echo '$(sqlite_dist_name)' | \
                             sed --silent 's/sqlite-\([0-9.]\+\)\.tar\..*/\1/p')
_sqlite_vers_toks := $(subst .,$(space),$(sqlite_vers))
sqlite_vers_maj   := $(word 1,$(_sqlite_vers_toks))
sqlite_vers_min   := $(word 2,$(_sqlite_vers_toks))

define fetch_sqlite_dist
$(call download,$(sqlite_dist_url),$(FETCHDIR)/$(sqlite_dist_name))
endef
$(call gen_fetch_rules,sqlite,sqlite_dist_name,fetch_sqlite_dist)

define xtract_sqlite
$(call rmrf,$(srcdir)/sqlite)
$(call untar,$(srcdir)/sqlite,\
             $(FETCHDIR)/$(sqlite_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sqlite,xtract_sqlite)

$(call gen_dir_rules,sqlite)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define sqlite_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/sqlite/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define sqlite_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define sqlite_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define sqlite_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define sqlite_uninstall_cmds
$(call rmf,$(strip $(3))$(strip $(2))/bin/sqlite$(sqlite_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/include/sqlite$(sqlite_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/pkgconfig/sqlite$(sqlite_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/libsqlite$(sqlite_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/tcltk/sqlite$(sqlite_vers_maj)/libtclsqlite$(sqlite_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/tcltk/sqlite$(sqlite_vers_maj)/pkgIndex.tcl)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/mann/sqlite$(sqlite_vers_maj)*)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define sqlite_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         test \
         LD_LIBRARY_PATH="$(stage_lib_path)"
endef

sqlite_common_config_args = \
	--enable-releasemode \
	--enable-shared \
	--enable-static \
	--enable-readline \
	--enable-all \
	--enable-update-limit \
	--enable-tempstore=yes \
	--enable-memsys5 \
	--with-tcl="$(builddir)/stage-tcl" \
	ac_cv_search_tgetent="-ltinfo"

################################################################################
# Staging definitions
################################################################################

sqlite_stage_config_args := \
	$(sqlite_common_config_args) \
	MAKEINFO=true \
	TCLLIBDIR='$(stagedir)/lib/tcltk/sqlite$(sqlite_vers_maj)' \
	$(stage_config_flags)

$(call gen_deps,stage-sqlite,stage-readline stage-zlib stage-tcl)

config_stage-sqlite    = $(call sqlite_config_cmds,\
                                 stage-sqlite,\
                                 $(stagedir),\
                                 $(sqlite_stage_config_args))
build_stage-sqlite     = $(call sqlite_build_cmds,stage-sqlite)
clean_stage-sqlite     = $(call sqlite_clean_cmds,stage-sqlite)
install_stage-sqlite   = $(call sqlite_install_cmds,stage-sqlite)
uninstall_stage-sqlite = $(call sqlite_uninstall_cmds,stage-sqlite,$(stagedir))
check_stage-sqlite     = $(call sqlite_check_cmds,stage-sqlite)

$(call gen_config_rules_with_dep,stage-sqlite,sqlite,config_stage-sqlite)
$(call gen_clobber_rules,stage-sqlite)
$(call gen_build_rules,stage-sqlite,build_stage-sqlite)
$(call gen_clean_rules,stage-sqlite,clean_stage-sqlite)
$(call gen_install_rules,stage-sqlite,install_stage-sqlite)
$(call gen_uninstall_rules,stage-sqlite,uninstall_stage-sqlite)
$(call gen_check_rules,stage-sqlite,check_stage-sqlite)
$(call gen_dir_rules,stage-sqlite)

################################################################################
# Final definitions
################################################################################

sqlite_final_config_args := \
	$(sqlite_common_config_args) \
	TCLLIBDIR='$(PREFIX)/lib/tcltk/sqlite$(sqlite_vers_maj)' \
	$(final_config_flags)

$(call gen_deps,final-sqlite,stage-readline stage-zlib stage-tcl)

config_final-sqlite    = $(call sqlite_config_cmds,\
                                 final-sqlite,\
                                 $(PREFIX),\
                                 $(sqlite_final_config_args))
build_final-sqlite     = $(call sqlite_build_cmds,final-sqlite)
clean_final-sqlite     = $(call sqlite_clean_cmds,final-sqlite)
install_final-sqlite   = $(call sqlite_install_cmds,final-sqlite,$(finaldir))
uninstall_final-sqlite = $(call sqlite_uninstall_cmds,final-sqlite,\
                                                      $(PREFIX),\
                                                      $(finaldir))
check_final-sqlite     = $(call sqlite_check_cmds,final-sqlite)

$(call gen_config_rules_with_dep,final-sqlite,sqlite,config_final-sqlite)
$(call gen_clobber_rules,final-sqlite)
$(call gen_build_rules,final-sqlite,build_final-sqlite)
$(call gen_clean_rules,final-sqlite,clean_final-sqlite)
$(call gen_install_rules,final-sqlite,install_final-sqlite)
$(call gen_uninstall_rules,final-sqlite,uninstall_final-sqlite)
$(call gen_check_rules,final-sqlite,check_final-sqlite)
$(call gen_dir_rules,final-sqlite)
