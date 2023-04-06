################################################################################
# popt modules
################################################################################

popt_dist_url  := https://github.com/rpm-software-management/popt/archive/refs/tags/popt-1.19-release.tar.gz
popt_dist_sum  := 021c6d7c4ef837de8cad48641700e5fba3baf8c7d381fd3717ee49b5da5ed4277e985db265ad4c2708e192d50de84eb0a54e11bc15951d0d45d5cd3fd02d32d4
popt_dist_name := $(notdir $(popt_dist_url))
popt_vers      := $(patsubst popt-%.tar.gz,%,$(popt_dist_name))
popt_brief     := Library for parsing cmdline parameters
popt_home      := https://github.com/rpm-software-management/popt

define popt_desc
Popt was heavily influenced by the getopt() and getopt_long() functions, but it
allows more powerful argument expansion. It can parse arbitrary argv[] style
arrays and automatically set variables based on command line arguments. It also
allows command line arguments to be aliased via configuration files and includes
utility functions for parsing arbitrary strings into argv[] arrays using
shell-like rules.
endef

define fetch_popt_dist
$(call download_csum,$(popt_dist_url),\
                     $(FETCHDIR)/$(popt_dist_name),\
                     $(popt_dist_sum))
endef
$(call gen_fetch_rules,popt,popt_dist_name,fetch_popt_dist)

define xtract_popt
$(call rmrf,$(srcdir)/popt)
$(call untar,$(srcdir)/popt,\
             $(FETCHDIR)/$(popt_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,popt,xtract_popt)

$(call gen_dir_rules,popt)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define popt_config_cmds
if [ ! -f "$(srcdir)/popt/configure" ]; then \
	cd $(srcdir)/popt && \
	env PATH="$(stagedir)/bin:$(PATH)" $(srcdir)/popt/autogen.sh; \
fi
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/popt/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define popt_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         $(verbose)
endef

# $(1): targets base name / module name
define popt_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
	clean \
	$(verbose)
endef

# $(1): targets base name / module name
# $(2): build /install prefix
# $(3): optional install destination directory
define popt_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define popt_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define popt_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

popt_common_config_args := --enable-silent-rules \
                           --enable-shared \
                           --enable-static

################################################################################
# Staging definitions
################################################################################

popt_stage_config_args := $(popt_common_config_args) \
                          --disable-nls \
                          MISSING='true' \
                          $(stage_config_flags)

$(call gen_deps,stage-popt,stage-glib stage-flex stage-gettext)

config_stage-popt       = $(call popt_config_cmds,stage-popt,\
                                                  $(stagedir),\
                                                  $(popt_stage_config_args))
build_stage-popt        = $(call popt_build_cmds,stage-popt)
clean_stage-popt        = $(call popt_clean_cmds,stage-popt)
install_stage-popt      = $(call popt_install_cmds,stage-popt,$(stagedir))
uninstall_stage-popt    = $(call popt_uninstall_cmds,stage-popt,$(stagedir))
check_stage-popt        = $(call popt_check_cmds,stage-popt)

$(call gen_config_rules_with_dep,stage-popt,popt,config_stage-popt)
$(call gen_clobber_rules,stage-popt)
$(call gen_build_rules,stage-popt,build_stage-popt)
$(call gen_clean_rules,stage-popt,clean_stage-popt)
$(call gen_install_rules,stage-popt,install_stage-popt)
$(call gen_uninstall_rules,stage-popt,uninstall_stage-popt)
$(call gen_check_rules,stage-popt,check_stage-popt)
$(call gen_dir_rules,stage-popt)

################################################################################
# Final definitions
################################################################################

# Disable glibtest since may fail because of an existing system-wide development
# glib install conflicting with the one into stagedir. The right glib is
# selected anyway thanks to $(final_config_flags).
popt_final_config_args := $(popt_common_config_args) \
                          --enable-nls \
                          $(final_config_flags)

$(call gen_deps,final-popt,stage-glib stage-flex stage-doxygen stage-gettext)

config_final-popt       = $(call popt_config_cmds,final-popt,\
                                                  $(PREFIX),\
                                                  $(popt_final_config_args))
build_final-popt        = $(call popt_build_cmds,final-popt)
clean_final-popt        = $(call popt_clean_cmds,final-popt)
install_final-popt      = $(call popt_install_cmds,final-popt,\
                                                   $(PREFIX),\
                                                   $(finaldir))
uninstall_final-popt    = $(call popt_uninstall_cmds,final-popt,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-popt        = $(call popt_check_cmds,final-popt)

$(call gen_config_rules_with_dep,final-popt,popt,config_final-popt)
$(call gen_clobber_rules,final-popt)
$(call gen_build_rules,final-popt,build_final-popt)
$(call gen_clean_rules,final-popt,clean_final-popt)
$(call gen_install_rules,final-popt,install_final-popt)
$(call gen_uninstall_rules,final-popt,uninstall_final-popt)
$(call gen_check_rules,final-popt,check_final-popt)
$(call gen_dir_rules,final-popt)
