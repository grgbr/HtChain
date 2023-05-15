################################################################################
# expect modules
################################################################################

expect_dist_url  := https://sourceforge.net/projects/expect/files/Expect/5.45.4/expect5.45.4.tar.gz/download
expect_dist_sum  := a8dc25e8175f67e029e15cbcfca1705165c1c4cb2dd37eaaaebffb61e3ba132d9519cd73ca5add4c3358a2b0b7a91e878279e8d0b72143ff2c287fce07e4659a
expect_dist_name := $(patsubst expect%,expect-%,\
                               $(notdir $(subst /download,,$(expect_dist_url))))
expect_vers      := $(patsubst expect-%.tar.gz,%,$(expect_dist_name))
expect_brief     := Automates interactive applications
expect_home      := https://core.tcl.tk/expect/

define expect_desc
Expect is a tool for automating interactive applications according to a script.
Following the script, Expect knows what can be expected from a program and what
the correct response should be. Expect is also useful for testing these same
applications. And by adding Tk, you can also wrap interactive applications in
X11 GUIs. An interpreted language provides branching and high-level control
structures to direct the dialogue. In addition, the user can take control and
interact directly when desired, afterward returning control to the script.
endef

define fetch_expect_dist
$(call download_csum,$(expect_dist_url),\
                     $(expect_dist_name),\
                     $(expect_dist_sum))
endef
$(call gen_fetch_rules,expect,expect_dist_name,fetch_expect_dist)

define xtract_expect
$(call rmrf,$(srcdir)/expect)
$(call untar,$(srcdir)/expect,\
             $(FETCHDIR)/$(expect_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,expect,xtract_expect)

$(call gen_dir_rules,expect)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define expect_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/expect/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define expect_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define expect_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define _expect_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define expect_install_cmds
$(call _expect_install_cmds,$(1),$(installdir)/$(strip $(1)))
$(call _expect_install_cmds,$(1),$(2))
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define expect_uninstall_cmds
$(call uninstall_from_refdir,$(installdir)/$(strip $(1)),$(2))
$(call rmrf,$(installdir)/$(strip $(1)))
endef

# $(1): targets base name / module name
define expect_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) test
endef

expect_common_args := --enable-threads \
                      --enable-shared \
                      --with-tcl="$(builddir)/stage-tcl" \
                      --with-tclinclude="$(stagedir)/include/tcl" \
                      $(if $(mach_is_64bits),--enable-64bit)

################################################################################
# Staging definitions
################################################################################

expect_stage_config_args := $(expect_common_args) \
                            --libdir="$(stagedir)/lib/tcltk" \
                            $(stage_config_flags)

$(call gen_deps,stage-expect,stage-tcl)

config_stage-expect    = $(call expect_config_cmds,\
                                stage-expect,\
                                $(stagedir),\
                                $(expect_stage_config_args))
build_stage-expect     = $(call expect_build_cmds,stage-expect)
clean_stage-expect     = $(call expect_clean_cmds,stage-expect)
install_stage-expect   = $(call expect_install_cmds,stage-expect)
uninstall_stage-expect = $(call expect_uninstall_cmds,stage-expect)
check_stage-expect     = $(call expect_check_cmds,stage-expect)

$(call gen_config_rules_with_dep,stage-expect,expect,config_stage-expect)
$(call gen_clobber_rules,stage-expect)
$(call gen_build_rules,stage-expect,build_stage-expect)
$(call gen_clean_rules,stage-expect,clean_stage-expect)
$(call gen_install_rules,stage-expect,install_stage-expect)
$(call gen_uninstall_rules,stage-expect,uninstall_stage-expect)
$(call gen_check_rules,stage-expect,check_stage-expect)
$(call gen_dir_rules,stage-expect)

################################################################################
# Final definitions
################################################################################

expect_final_config_args := $(expect_common_args) \
                            --bindir="$(PREFIX)/bin" \
                            --libdir="$(PREFIX)/lib/tcltk" \
                            $(final_config_flags)

$(call gen_deps,final-expect,stage-tcl)

config_final-expect    = $(call expect_config_cmds,\
                                final-expect,\
                                $(PREFIX),\
                                $(expect_final_config_args))
build_final-expect     = $(call expect_build_cmds,final-expect)
clean_final-expect     = $(call expect_clean_cmds,final-expect)
install_final-expect   = $(call expect_install_cmds,final-expect,$(finaldir))
uninstall_final-expect = $(call expect_uninstall_cmds,final-expect,$(finaldir))
check_final-expect     = $(call expect_check_cmds,final-expect)

$(call gen_config_rules_with_dep,final-expect,expect,config_final-expect)
$(call gen_clobber_rules,final-expect)
$(call gen_build_rules,final-expect,build_final-expect)
$(call gen_clean_rules,final-expect,clean_final-expect)
$(call gen_install_rules,final-expect,install_final-expect)
$(call gen_uninstall_rules,final-expect,uninstall_final-expect)
$(call gen_check_rules,final-expect,check_final-expect)
$(call gen_dir_rules,final-expect)
