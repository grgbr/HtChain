################################################################################
# libunistring modules
################################################################################

libunistring_dist_url  := https://ftp.gnu.org/gnu/libunistring/libunistring-1.0.tar.xz
libunistring_dist_sum  := 70d5ad82722844dbeacdfcb4d7593358e4a00a9222a98537add4b7f0bf4a2bb503dfb3cd627e52e2a5ca1d3da9e5daf38a6bd521197f92002e11e715fb1662d1
libunistring_dist_name := $(notdir $(libunistring_dist_url))
libunistring_vers      := $(patsubst libunistring-%.tar.xz,%,$(libunistring_dist_name))
libunistring_brief     := Unicode string library for C
libunistring_home      := https://www.gnu.org/software/libunistring/

define libunistring_desc
The libunistring library implements Unicode strings (in the UTF-8, UTF-16, and
UTF-32 encodings), together with functions for Unicode characters (character
names, classifications, properties) and functions for string processing
(formatted output, width, word breaks, line breaks, normalization, case folding,
regular expressions).
endef

define fetch_libunistring_dist
$(call download_csum,$(libunistring_dist_url),\
                     $(libunistring_dist_name),\
                     $(libunistring_dist_sum))
endef
$(call gen_fetch_rules,libunistring,\
                       libunistring_dist_name,\
                       fetch_libunistring_dist)

define xtract_libunistring
$(call rmrf,$(srcdir)/libunistring)
$(call untar,$(srcdir)/libunistring,\
             $(FETCHDIR)/$(libunistring_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libunistring,xtract_libunistring)

$(call gen_dir_rules,libunistring)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libunistring_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libunistring/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libunistring_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define libunistring_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define libunistring_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libunistring_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Requires perl to run...
define libunistring_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

libunistring_common_config_args := --enable-threads=posix \
                                   --enable-shared \
                                   --enable-static

################################################################################
# Staging definitions
################################################################################

libunistring_stage_config_args := $(libunistring_common_config_args) \
                                  $(stage_config_flags)

$(call gen_deps,stage-libunistring,stage-gcc)

config_stage-libunistring    = $(call libunistring_config_cmds,\
                                      stage-libunistring,\
                                      $(stagedir),\
                                      $(libunistring_stage_config_args))
build_stage-libunistring     = $(call libunistring_build_cmds,\
                                      stage-libunistring)
clean_stage-libunistring     = $(call libunistring_clean_cmds,\
                                      stage-libunistring)
install_stage-libunistring   = $(call libunistring_install_cmds,\
                                      stage-libunistring)
uninstall_stage-libunistring = $(call libunistring_uninstall_cmds,\
                                      stage-libunistring,\
                                      $(stagedir))
check_stage-libunistring     = $(call libunistring_check_cmds,\
                                      stage-libunistring)

$(call gen_config_rules_with_dep,stage-libunistring,\
                                 libunistring,\
                                 config_stage-libunistring)
$(call gen_clobber_rules,stage-libunistring)
$(call gen_build_rules,stage-libunistring,build_stage-libunistring)
$(call gen_clean_rules,stage-libunistring,clean_stage-libunistring)
$(call gen_install_rules,stage-libunistring,install_stage-libunistring)
$(call gen_uninstall_rules,stage-libunistring,uninstall_stage-libunistring)
$(call gen_check_rules,stage-libunistring,check_stage-libunistring)
$(call gen_dir_rules,stage-libunistring)

################################################################################
# Final definitions
################################################################################

libunistring_final_config_args := $(libunistring_common_config_args) \
                                  $(final_config_flags)

$(call gen_deps,final-libunistring,stage-gcc)

config_final-libunistring    = $(call libunistring_config_cmds,\
                                      final-libunistring,\
                                      $(PREFIX),\
                                      $(libunistring_final_config_args))
build_final-libunistring     = $(call libunistring_build_cmds,\
                                      final-libunistring)
clean_final-libunistring     = $(call libunistring_clean_cmds,\
                                      final-libunistring)
install_final-libunistring   = $(call libunistring_install_cmds,\
                                      final-libunistring,\
                                      $(finaldir))
uninstall_final-libunistring = $(call libunistring_uninstall_cmds,\
                                      final-libunistring,\
                                      $(PREFIX),\
                                      $(finaldir))
check_final-libunistring     = $(call libunistring_check_cmds,\
                                      final-libunistring)

$(call gen_config_rules_with_dep,final-libunistring,\
                                 libunistring,\
                                 config_final-libunistring)
$(call gen_clobber_rules,final-libunistring)
$(call gen_build_rules,final-libunistring,build_final-libunistring)
$(call gen_clean_rules,final-libunistring,clean_final-libunistring)
$(call gen_install_rules,final-libunistring,install_final-libunistring)
$(call gen_uninstall_rules,final-libunistring,uninstall_final-libunistring)
$(call gen_check_rules,final-libunistring,check_final-libunistring)
$(call gen_dir_rules,final-libunistring)
