################################################################################
# glib modules
################################################################################

glib_dist_url  := https://download.gnome.org/sources/glib/2.75/glib-2.75.4.tar.xz
glib_dist_sum  := 520ebedb54d6b2ab5771452b9fec331ebf32a12b8b6590ae0edc70db5f1b7af89865e4ba9ecf189464fe82312c2e0fa03a5cbff0ab2e8cc16d41705c605c6d91
glib_dist_name := $(notdir $(glib_dist_url))
glib_vers      := $(patsubst glib-%.tar.xz,%,$(glib_dist_name))
glib_brief     := GLib library of C routines
glib_home      := https://wiki.gnome.org/Projects/GLib

define glib_desc
GLib is a library containing many useful C routines for things such as trees,
hashes, lists, and strings. It is a useful general-purpose C library used by
projects such as GTK+, GIMP, and GNOME.
endef

define fetch_glib_dist
$(call download_csum,$(glib_dist_url),\
                     $(FETCHDIR)/$(glib_dist_name),\
                     $(glib_dist_sum))
endef
$(call gen_fetch_rules,glib,glib_dist_name,fetch_glib_dist)

define xtract_glib
$(call rmrf,$(srcdir)/glib)
$(call untar,$(srcdir)/glib,\
             $(FETCHDIR)/$(glib_dist_name),\
             --strip-components=1)
cd $(srcdir)/glib && \
patch -p1 < $(PATCHDIR)/glib-2.75.4-000-fix_spawn_singlethread_test_on_debian.patch
cd $(srcdir)/glib && \
patch -p1 < $(PATCHDIR)/glib-2.75.4-001-fix_test_env_LD_LIBRARY_PATH.patch
endef
$(call gen_xtract_rules,glib,xtract_glib)

$(call gen_dir_rules,glib)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure environment
# $(4): configure arguments
define glib_config_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    SSL_CERT_DIR="/etc/ssl/certs" \
    $(3) \
$(stage_meson) setup --prefix "$(strip $(2))" \
                     --libdir "$(strip $(2))/lib" \
                     --buildtype release \
                     $(4) \
                     "$(builddir)/$(strip $(1))" \
                     "$(srcdir)/glib"
endef

# $(1): targets base name / module name
define glib_build_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stage_meson) compile -C $(builddir)/$(strip $(1)) \
                       $(if $(strip $(V)),--verbose)
endef

# $(1): targets base name / module name
define glib_clean_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
$(stage_meson) compile -C $(builddir)/$(strip $(1)) \
                       --ninja-args 'clean' \
                       $(if $(strip $(V)),--verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define glib_install_cmds
env PATH="$(stagedir)/bin:$(PATH)" \
$(stage_meson) install -C $(builddir)/$(strip $(1)) \
                       --no-rebuild \
                       $(if $(strip $(2)),--destdir "$(strip $(2))") \
                       $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define glib_uninstall_cmds
-env PATH="$(stagedir)/bin:$(PATH)" \
 $(stage_meson) compile -C $(builddir)/$(strip $(1)) \
                       --ninja-args 'uninstall' \
                       $(if $(strip $(V)),--verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Setup umask to make "17/357 glib:glib+core / fileutils" test pass since it
# expects umask to be 0022...
define glib_check_cmds
umask 0022; \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stage_meson) test -C $(builddir)/$(strip $(1)) \
                    --no-rebuild \
                    $(if $(strip $(V)),--verbose)
endef

# TODO: enable man page generation (requires libxslt and internet access to
#       download man page docbook definitions)
glib_common_config_args := -Ddefault_library=both \
                           -Ddtrace=false \
                           -Dsystemtap=false \
                           -Dbsymbolic_functions=true \
                           -Dxattr=true \
                           -Db_coverage=false \
                           -Dglib_debug=disabled \
                           -Dinstalled_tests=false \
                           -Dlibmount=enabled \
                           -Dlibelf=enabled \
                           -Dman=false

################################################################################
# Staging definitions
################################################################################

glib_stage_config_env  := $(stage_config_flags)
glib_stage_config_args := $(glib_common_config_args) \
                          -Dnls=disabled

$(call gen_deps,stage-glib,stage-meson \
                           stage-attr \
                           stage-util-linux \
                           stage-pcre2 \
                           stage-elfutils)

config_stage-glib       = $(call glib_config_cmds,stage-glib,\
                                                  $(stagedir),\
                                                  $(glib_stage_config_env),\
                                                  $(glib_stage_config_args))
build_stage-glib        = $(call glib_build_cmds,stage-glib)
clean_stage-glib        = $(call glib_clean_cmds,stage-glib)
install_stage-glib      = $(call glib_install_cmds,stage-glib)
uninstall_stage-glib    = $(call glib_uninstall_cmds,stage-glib,$(stagedir))
check_stage-glib        = $(call glib_check_cmds,stage-glib)

$(call gen_config_rules_with_dep,stage-glib,glib,config_stage-glib)
$(call gen_clobber_rules,stage-glib)
$(call gen_build_rules,stage-glib,build_stage-glib)
$(call gen_clean_rules,stage-glib,clean_stage-glib)
$(call gen_install_rules,stage-glib,install_stage-glib)
$(call gen_uninstall_rules,stage-glib,uninstall_stage-glib)
$(call gen_check_rules,stage-glib,check_stage-glib)
$(call gen_dir_rules,stage-glib)

################################################################################
# Final definitions
################################################################################

glib_final_config_env  := $(final_config_flags)
glib_final_config_args := $(glib_common_config_args) \
                          -Dnls=enabled

$(call gen_deps,final-glib,stage-meson \
                           stage-attr \
                           stage-util-linux \
                           stage-pcre2 \
                           stage-gettext \
                           stage-elfutils)

config_final-glib       = $(call glib_config_cmds,final-glib,\
                                                  $(PREFIX),\
                                                  $(glib_final_config_env),\
                                                  $(glib_final_config_args))
build_final-glib        = $(call glib_build_cmds,final-glib)
clean_final-glib        = $(call glib_clean_cmds,final-glib)

final-glib_shebang_fixups := bin/glib-mkenums \
                             bin/glib-genmarshal \
                             bin/gdbus-codegen \
                             bin/gtester-report

define install_final-glib
 $(call glib_install_cmds,final-glib,$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-glib_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

uninstall_final-glib    = $(call glib_uninstall_cmds,final-glib,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-glib        = $(call glib_check_cmds,final-glib)

$(call gen_config_rules_with_dep,final-glib,glib,config_final-glib)
$(call gen_clobber_rules,final-glib)
$(call gen_build_rules,final-glib,build_final-glib)
$(call gen_clean_rules,final-glib,clean_final-glib)
$(call gen_install_rules,final-glib,install_final-glib)
$(call gen_uninstall_rules,final-glib,uninstall_final-glib)
$(call gen_check_rules,final-glib,check_final-glib)
$(call gen_dir_rules,final-glib)
