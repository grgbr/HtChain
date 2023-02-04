################################################################################
# bison modules
################################################################################

bison_dist_url  := https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.lz
bison_dist_sum  := b04fca1b6dc211e9c2882848957369291b1af35601990b5459f06df962c2a92a870727ea8f62384e0bd56f7f3bda01d7ce38da4d43b4c49d4fbbd8ab0713c675
bison_dist_name := $(notdir $(bison_dist_url))
bison_vers      := $(patsubst bison-%.tar.lz,%,$(bison_dist_name))
bison_brief     := YACC-compatible parser generator
bison_home      := https://www.gnu.org/software/bison/

define bison_desc
Bison is a general-purpose parser generator that converts a grammar description
for an LALR(1) context-free grammar into a C program to parse that grammar. Once
you are proficient with Bison, you may use it to develop a wide range of
language parsers, from those used in simple desk calculators to complex
programming languages.

Bison is upward compatible with :manpage:`yacc(1p)`: all properly-written
:manpage:`yacc(1p)` grammars ought to work with Bison with no change. Anyone
familiar with :manpage:`yacc(1p)` should be able to use Bison with little
trouble.
endef

define fetch_bison_dist
$(call download_csum,$(bison_dist_url),\
                     $(FETCHDIR)/$(bison_dist_name),\
                     $(bison_dist_sum))
endef
$(call gen_fetch_rules,bison,bison_dist_name,fetch_bison_dist)

define xtract_bison
$(call rmrf,$(srcdir)/bison)
$(call untar,$(srcdir)/bison,\
             $(FETCHDIR)/$(bison_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,bison,xtract_bison)

$(call gen_dir_rules,bison)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define bison_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/bison/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define bison_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define bison_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define bison_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define bison_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define bison_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) check
endef

bison_common_config_args := --enable-silent-rules \
                            --enable-threads=posix \
                            --disable-assert

################################################################################
# Staging definitions
################################################################################

bison_stage_config_args := $(bison_common_args) \
                           --disable-nls \
                           MISSING='true' \
                           $(filter-out FLEX=% LEX=%,$(stage_config_flags))

$(call gen_deps,stage-bison,stage-gcc stage-m4)
$(call gen_check_deps,stage-bison,stage-perl)

config_stage-bison       = $(call bison_config_cmds,stage-bison,\
                                                    $(stagedir),\
                                                    $(bison_stage_config_args))
build_stage-bison        = $(call bison_build_cmds,stage-bison)
clean_stage-bison        = $(call bison_clean_cmds,stage-bison)
install_stage-bison      = $(call bison_install_cmds,stage-bison)
uninstall_stage-bison    = $(call bison_uninstall_cmds,stage-bison,$(stagedir))
check_stage-bison        = $(call bison_check_cmds,stage-bison)

$(call gen_config_rules_with_dep,stage-bison,bison,config_stage-bison)
$(call gen_clobber_rules,stage-bison)
$(call gen_build_rules,stage-bison,build_stage-bison)
$(call gen_clean_rules,stage-bison,clean_stage-bison)
$(call gen_install_rules,stage-bison,install_stage-bison)
$(call gen_uninstall_rules,stage-bison,uninstall_stage-bison)
$(call gen_check_rules,stage-bison,check_stage-bison)
$(call gen_dir_rules,stage-bison)

################################################################################
# Final definitions
################################################################################

bison_final_config_args := $(bison_common_args) \
                           $(final_config_flags)

$(call gen_deps,final-bison,stage-gcc stage-m4)
$(call gen_check_deps,final-bison,stage-perl)

config_final-bison       = $(call bison_config_cmds,final-bison,\
                                                    $(PREFIX),\
                                                    $(bison_final_config_args))
build_final-bison        = $(call bison_build_cmds,final-bison)
clean_final-bison        = $(call bison_clean_cmds,final-bison)
install_final-bison      = $(call bison_install_cmds,final-bison,$(finaldir))
uninstall_final-bison    = $(call bison_uninstall_cmds,final-bison,\
                                                 $(PREFIX),\
                                                 $(finaldir))
check_final-bison        = $(call bison_check_cmds,final-bison)

$(call gen_config_rules_with_dep,final-bison,bison,config_final-bison)
$(call gen_clobber_rules,final-bison)
$(call gen_build_rules,final-bison,build_final-bison)
$(call gen_clean_rules,final-bison,clean_final-bison)
$(call gen_install_rules,final-bison,install_final-bison)
$(call gen_uninstall_rules,final-bison,uninstall_final-bison)
$(call gen_check_rules,final-bison,check_final-bison)
$(call gen_dir_rules,final-bison)
