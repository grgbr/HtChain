################################################################################
# gettext modules
#
# TODO:
# * depends on bison glib2 libcroco (see <gettext>/DEPENDENCIES)
################################################################################

gettext_dist_url  := https://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.xz
gettext_dist_sum  := f7e2968651879f8444d43a176a149db9f9411f4a03132a7f3b37c2ed97e3978ae6888169c995c1953cb78943b6e3573811abcbb8661b6631edbbe067b2699ddf
gettext_dist_name := $(notdir $(gettext_dist_url))
gettext_vers      := $(patsubst gettext-%.tar.xz,%,$(gettext_dist_name))
gettext_brief     := GNU Internationalization utilities
gettext_home      := https://www.gnu.org/software/gettext/

define gettext_desc
Interesting for authors or maintainers of other packages or programs which they
want to see internationalized.
endef

define fetch_gettext_dist
$(call download_csum,$(gettext_dist_url),\
                     $(gettext_dist_name),\
                     $(gettext_dist_sum))
endef
$(call gen_fetch_rules,gettext,gettext_dist_name,fetch_gettext_dist)

define xtract_gettext
$(call rmrf,$(srcdir)/gettext)
$(call untar,$(srcdir)/gettext,\
             $(FETCHDIR)/$(gettext_dist_name),\
             --strip-components=1)
cd $(srcdir)/gettext && \
patch -p1 < $(PATCHDIR)/gettext-0.21-000-update_test_for_changed_libunistring_line_breaking_behaviour.patch
cd $(srcdir)/gettext && \
patch -p1 < $(PATCHDIR)/gettext-0.21-001-fix_supersede_test.patch
endef
$(call gen_xtract_rules,gettext,xtract_gettext)

$(call gen_dir_rules,gettext)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gettext_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/gettext/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define gettext_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define gettext_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define gettext_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gettext_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define gettext_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)'
endef

gettext_common_config_args := --enable-silent-rules \
                              --disable-java \
                              --enable-threads \
                              --enable-shared \
                              --enable-static \
                              --enable-c++ \
                              --enable-acl \
                              --with-libncurses-prefix="$(stagedir)" \
                              --with-libunistring-prefix="$(stagedir)" \
                              --with-libxml2-prefix="$(stagedir)" \
                              --with-bzip2 \
                              --with-xz

################################################################################
# Staging definitions
################################################################################

gettext_stage_config_args := $(gettext_common_config_args) \
                             --disable-nls \
                             MAKEINFO=true \
                             $(stage_config_flags)

$(call gen_deps,stage-gettext,stage-bzip2 \
                              stage-xz-utils \
                              stage-acl \
                              stage-libunistring \
                              stage-libxml2 \
                              stage-ncurses \
                              stage-pkg-config \
                              stage-perl \
                              stage-python)

config_stage-gettext    = $(call gettext_config_cmds,\
                                 stage-gettext,\
                                 $(stagedir),\
                                 $(gettext_stage_config_args))
build_stage-gettext     = $(call gettext_build_cmds,stage-gettext)
clean_stage-gettext     = $(call gettext_clean_cmds,stage-gettext)
install_stage-gettext   = $(call gettext_install_cmds,stage-gettext)
uninstall_stage-gettext = $(call gettext_uninstall_cmds,\
                                 stage-gettext,\
                                 $(stagedir))
check_stage-gettext     = $(call gettext_check_cmds,stage-gettext)

$(call gen_config_rules_with_dep,stage-gettext,gettext,config_stage-gettext)
$(call gen_clobber_rules,stage-gettext)
$(call gen_build_rules,stage-gettext,build_stage-gettext)
$(call gen_clean_rules,stage-gettext,clean_stage-gettext)
$(call gen_install_rules,stage-gettext,install_stage-gettext)
$(call gen_uninstall_rules,stage-gettext,uninstall_stage-gettext)
$(call gen_check_rules,stage-gettext,check_stage-gettext)
$(call gen_dir_rules,stage-gettext)

################################################################################
# Final definitions
################################################################################

gettext_final_config_args := \
	$(gettext_common_config_args) \
	--enable-nls \
	--disable-rpath \
	$(final_config_flags) \
	LT_SYS_LIBRARY_PATH="$(subst :,$(space),$(stage_lib_path))"

$(call gen_deps,final-gettext,stage-bzip2 \
                              stage-xz-utils \
                              stage-acl \
                              stage-libunistring \
                              stage-libxml2 \
                              stage-ncurses \
                              stage-pkg-config \
                              stage-perl \
                              stage-python \
                              stage-chrpath \
                              stage-texinfo)

config_final-gettext    = $(call gettext_config_cmds,\
                                 final-gettext,\
                                 $(PREFIX),\
                                 $(gettext_final_config_args))
build_final-gettext     = $(call gettext_build_cmds,final-gettext)
clean_final-gettext     = $(call gettext_clean_cmds,final-gettext)

define install_final-gettext
$(call gettext_install_cmds,final-gettext,$(finaldir))
$(call fixup_rpath,$(finaldir)$(PREFIX)/lib/libasprintf.so,\
                   $(final_lib_path))
endef

uninstall_final-gettext = $(call gettext_uninstall_cmds,\
                                 final-gettext,\
                                 $(PREFIX),\
                                 $(finaldir))
check_final-gettext     = $(call gettext_check_cmds,final-gettext)

$(call gen_config_rules_with_dep,final-gettext,gettext,config_final-gettext)
$(call gen_clobber_rules,final-gettext)
$(call gen_build_rules,final-gettext,build_final-gettext)
$(call gen_clean_rules,final-gettext,clean_final-gettext)
$(call gen_install_rules,final-gettext,install_final-gettext)
$(call gen_uninstall_rules,final-gettext,uninstall_final-gettext)
$(call gen_check_rules,final-gettext,check_final-gettext)
$(call gen_dir_rules,final-gettext)
