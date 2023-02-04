################################################################################
# dejagnu modules
################################################################################

dejagnu_dist_url  := https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz
dejagnu_dist_sum  := 1a737132bd912cb527e7f2fcbe70ffff8ccc8604a0ffdecff87ba2a16aeeefd800f5792aeffdbe79be6daa35cedb1c60e41002ca4aabb5370a460028191b76c4
dejagnu_dist_name := $(notdir $(dejagnu_dist_url))
dejagnu_vers      := $(patsubst dejagnu-%.tar.gz,%,$(dejagnu_dist_name))
dejagnu_brief     := Framework for running test suites on software tools
dejagnu_home      := https://www.gnu.org/s/dejagnu/

define dejagnu_desc
DejaGnu is a framework for testing other programs. Its purpose is to provide a
single front end for all tests.

DejaGnu provides a layer of abstraction which allows you to write tests that are
portable to any host or target where a program must be tested. All tests have
the same output format.

DejaGnu is written in expect_, which in turn uses Tcl_.
endef

define fetch_dejagnu_dist
$(call download_csum,$(dejagnu_dist_url),\
                     $(FETCHDIR)/$(dejagnu_dist_name),\
                     $(dejagnu_dist_sum))
endef
$(call gen_fetch_rules,dejagnu,dejagnu_dist_name,fetch_dejagnu_dist)

define xtract_dejagnu
$(call rmrf,$(srcdir)/dejagnu)
$(call untar,$(srcdir)/dejagnu,\
             $(FETCHDIR)/$(dejagnu_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,dejagnu,xtract_dejagnu)

$(call gen_dir_rules,dejagnu)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define dejagnu_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/dejagnu/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define dejagnu_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define dejagnu_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define dejagnu_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define dejagnu_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): path to expect binary
define dejagnu_check_cmds
+$(MAKE) -j1 \
         --directory $(builddir)/$(strip $(1)) \
         EXPECT="$(stage_expect)" \
         check
endef

################################################################################
# Staging definitions
################################################################################

dejagnu_stage_config_args := --enable-silent-rules \
                             MAKEINFO=true \
                             $(stage_config_flags)

$(call gen_deps,stage-dejagnu,stage-expect)

config_stage-dejagnu    = $(call dejagnu_config_cmds,\
                                 stage-dejagnu,\
                                 $(stagedir),\
                                 $(dejagnu_stage_config_args))
build_stage-dejagnu     = $(call dejagnu_build_cmds,stage-dejagnu)
clean_stage-dejagnu     = $(call dejagnu_clean_cmds,stage-dejagnu)
install_stage-dejagnu   = $(call dejagnu_install_cmds,stage-dejagnu)
uninstall_stage-dejagnu = $(call dejagnu_uninstall_cmds,stage-dejagnu,\
                                                        $(stagedir))
check_stage-dejagnu     = $(call dejagnu_check_cmds,stage-dejagnu)

$(call gen_config_rules_with_dep,stage-dejagnu,dejagnu,config_stage-dejagnu)
$(call gen_clobber_rules,stage-dejagnu)
$(call gen_build_rules,stage-dejagnu,build_stage-dejagnu)
$(call gen_clean_rules,stage-dejagnu,clean_stage-dejagnu)
$(call gen_install_rules,stage-dejagnu,install_stage-dejagnu)
$(call gen_uninstall_rules,stage-dejagnu,uninstall_stage-dejagnu)
$(call gen_check_rules,stage-dejagnu,check_stage-dejagnu)
$(call gen_dir_rules,stage-dejagnu)

################################################################################
# Final definitions
################################################################################

dejagnu_final_config_args := --enable-silent-rules \
                             $(final_config_flags)

$(call gen_deps,final-dejagnu,stage-expect)

config_final-dejagnu    = $(call dejagnu_config_cmds,\
                                 final-dejagnu,\
                                 $(PREFIX),\
                                 $(dejagnu_final_config_args))
build_final-dejagnu     = $(call dejagnu_build_cmds,final-dejagnu)
clean_final-dejagnu     = $(call dejagnu_clean_cmds,final-dejagnu)
install_final-dejagnu   = $(call dejagnu_install_cmds,final-dejagnu,\
                                                      $(finaldir))
uninstall_final-dejagnu = $(call dejagnu_uninstall_cmds,final-dejagnu,\
                                                        $(PREFIX),\
                                                        $(finaldir))
check_final-dejagnu     = $(call dejagnu_check_cmds,final-dejagnu)

$(call gen_config_rules_with_dep,final-dejagnu,dejagnu,config_final-dejagnu)
$(call gen_clobber_rules,final-dejagnu)
$(call gen_build_rules,final-dejagnu,build_final-dejagnu)
$(call gen_clean_rules,final-dejagnu,clean_final-dejagnu)
$(call gen_install_rules,final-dejagnu,install_final-dejagnu)
$(call gen_uninstall_rules,final-dejagnu,uninstall_final-dejagnu)
$(call gen_check_rules,final-dejagnu,check_final-dejagnu)
$(call gen_dir_rules,final-dejagnu)
