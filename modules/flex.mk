################################################################################
# flex modules
#
# TODO:
# * depends on gettext automake texinfo
# * depends on autoconf / m4 ?
################################################################################

flex_dist_url  := https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.lz
flex_dist_sum  := 95173d8a979cc8109ec45b3a35130d5e57af6e43d5f11d5b989e5eab2f520b2bc910b83a92172878d6ffa84acefd62e8c252313741bcf16cb7e1ae0b211e1c85
flex_dist_name := $(notdir $(flex_dist_url))
flex_vers      := $(patsubst flex-%.tar.lz,%,$(flex_dist_name))
flex_brief     := Fast lexical analyzer generator
flex_home      := https://github.com/westes/flex

define flex_desc
Flex is a tool for generating scanners: programs which recognized lexical
patterns in text. It reads the given input files for a description of a scanner
to generate. The description is in the form of pairs of regular expressions and
C code, called rules. Flex generates as output a C source file,
:file:`lex.yy.c`, which defines a routine ``yylex()``.  This file is compiled
and linked with the ``-lfl`` library to produce an executable. When the
executable is run, it analyzes its input for occurrences of the regular
expressions. Whenever it finds one, it executes the corresponding C code.
endef

define fetch_flex_dist
$(call download_csum,$(flex_dist_url),\
                     $(FETCHDIR)/$(flex_dist_name),\
                     $(flex_dist_sum))
endef
$(call gen_fetch_rules,flex,flex_dist_name,fetch_flex_dist)

define xtract_flex
$(call rmrf,$(srcdir)/flex)
$(call untar,$(srcdir)/flex,\
             $(FETCHDIR)/$(flex_dist_name),\
             --strip-components=1)
cd $(srcdir)/flex && \
	patch -p1 < $(PATCHDIR)/flex-2.6.4-000-build_ac_use_system_extensions_in_configure_ac.patch
endef
$(call gen_xtract_rules,flex,xtract_flex)

$(call gen_dir_rules,flex)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define flex_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/flex/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define flex_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define flex_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define flex_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define flex_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define flex_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

flex_common_config_args := --enable-silent-rules \
                           --enable-threads=posix \
                           --disable-assert

################################################################################
# Staging definitions
################################################################################

flex_stage_config_args := --enable-silent-rules \
                          --disable-nls \
                          MISSING='true' \
                          $(filter-out FLEX=% LEX=%,$(stage_config_flags))

$(call gen_deps,stage-flex,stage-bison)

config_stage-flex       = $(call flex_config_cmds,stage-flex,\
                                                  $(stagedir),\
                                                  $(flex_stage_config_args))
build_stage-flex        = $(call flex_build_cmds,stage-flex)
clean_stage-flex        = $(call flex_clean_cmds,stage-flex)
install_stage-flex      = $(call flex_install_cmds,stage-flex)
uninstall_stage-flex    = $(call flex_uninstall_cmds,stage-flex,$(stagedir))
check_stage-flex        = $(call flex_check_cmds,stage-flex)

$(call gen_config_rules_with_dep,stage-flex,flex,config_stage-flex)
$(call gen_clobber_rules,stage-flex)
$(call gen_build_rules,stage-flex,build_stage-flex)
$(call gen_clean_rules,stage-flex,clean_stage-flex)
$(call gen_install_rules,stage-flex,install_stage-flex)
$(call gen_uninstall_rules,stage-flex,uninstall_stage-flex)
$(call gen_check_rules,stage-flex,check_stage-flex)
$(call gen_dir_rules,stage-flex)

################################################################################
# Final definitions
################################################################################

flex_final_config_args := --enable-silent-rules \
                          --enable-nls \
                          MISSING='true' \
                          YACC="$(stage_yacc)" \
                          $(final_config_flags)

$(call gen_deps,final-flex,stage-bison stage-flex)

config_final-flex       = $(call flex_config_cmds,final-flex,\
                                                    $(PREFIX),\
                                                    $(flex_final_config_args))
build_final-flex        = $(call flex_build_cmds,final-flex)
clean_final-flex        = $(call flex_clean_cmds,final-flex)
install_final-flex      = $(call flex_install_cmds,final-flex,$(finaldir))
uninstall_final-flex    = $(call flex_uninstall_cmds,final-flex,\
                                                 $(PREFIX),\
                                                 $(finaldir))
check_final-flex        = $(call flex_check_cmds,final-flex)

$(call gen_config_rules_with_dep,final-flex,flex,config_final-flex)
$(call gen_clobber_rules,final-flex)
$(call gen_build_rules,final-flex,build_final-flex)
$(call gen_clean_rules,final-flex,clean_final-flex)
$(call gen_install_rules,final-flex,install_final-flex)
$(call gen_uninstall_rules,final-flex,uninstall_final-flex)
$(call gen_check_rules,final-flex,check_final-flex)
$(call gen_dir_rules,final-flex)
