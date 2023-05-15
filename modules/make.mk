################################################################################
# GNU make modules
################################################################################

make_dist_url  := https://ftp.gnu.org/gnu/make/make-4.3.tar.lz
make_dist_sum  := ddf0fdcb9ee1b182ef294c5da70c1275288c99bef60e63a25c0abed2ddd44aba1770be4aab1db8cac81e5f624576f2127c5d825a1824e1c7a49df4f16445526b
make_dist_name := $(notdir $(make_dist_url))
make_vers      := $(patsubst make-%.tar.lz,%,$(make_dist_name))
make_brief     := Utility for directing compilation
make_home      := https://www.gnu.org/software/make/

define make_desc
GNU Make is a utility which controls the generation of executables and other
target files of a program from the program\'s source files. It determines
automatically which pieces of a large program need to be (re)created, and issues
the commands to (re)create them. Make can be used to organize any task in which
targets (files) are to be automatically updated based on input files whenever
the corresponding input is newer --- it is not limited to building computer
programs. Indeed, Make is a general purpose dependency solver.
endef

define fetch_make_dist
$(call download_csum,$(make_dist_url),\
                     $(make_dist_name),\
                     $(make_dist_sum))
endef
$(call gen_fetch_rules,make,make_dist_name,fetch_make_dist)

define xtract_make
$(call rmrf,$(srcdir)/make)
$(call untar,$(srcdir)/make,\
             $(FETCHDIR)/$(make_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,make,xtract_make)

$(call gen_dir_rules,make)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define make_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/make/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define make_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define make_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define make_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define make_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define make_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

################################################################################
# Staging definitions
################################################################################

#make_stage_config_args := --enable-silent-rules \
#                          --disable-nls \
#                          MISSING=true \
#                          $(call stage_config_flags,$(rpath_flags))
#
#$(call gen_deps,stage-make,stage-gcc)
#
#config_stage-make       = $(call make_config_cmds,stage-make,\
#                                                  $(stagedir),\
#                                                  $(make_stage_config_args))
#build_stage-make        = $(call make_build_cmds,stage-make)
#clean_stage-make        = $(call make_clean_cmds,stage-make)
#install_stage-make      = $(call make_install_cmds,stage-make)
#uninstall_stage-make    = $(call make_uninstall_cmds,stage-make,$(stagedir))
#check_stage-make        = $(call make_check_cmds,stage-make)
#
#$(call gen_config_rules_with_dep,stage-make,make,config_stage-make)
#$(call gen_clobber_rules,stage-make)
#$(call gen_build_rules,stage-make,build_stage-make)
#$(call gen_clean_rules,stage-make,clean_stage-make)
#$(call gen_install_rules,stage-make,install_stage-make)
#$(call gen_uninstall_rules,stage-make,uninstall_stage-make)
#$(call gen_check_rules,stage-make,check_stage-make)
#$(call gen_dir_rules,stage-make)

################################################################################
# Final definitions
################################################################################

make_final_config_args := --enable-silent-rules \
                          --enable-nls \
                          --with-guile \
                          $(final_config_flags)

$(call gen_deps,final-make,stage-gcc \
                           stage-texinfo \
                           stage-perl \
                           stage-pkg-config \
                           stage-gettext \
                           stage-guile)

config_final-make       = $(call make_config_cmds,final-make,\
                                                  $(PREFIX),\
                                                  $(make_final_config_args))
build_final-make        = $(call make_build_cmds,final-make)
clean_final-make        = $(call make_clean_cmds,final-make)
install_final-make      = $(call make_install_cmds,final-make,$(finaldir))
uninstall_final-make    = $(call make_uninstall_cmds,final-make,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-make        = $(call make_check_cmds,final-make)

$(call gen_config_rules_with_dep,final-make,make,config_final-make)
$(call gen_clobber_rules,final-make)
$(call gen_build_rules,final-make,build_final-make)
$(call gen_clean_rules,final-make,clean_final-make)
$(call gen_install_rules,final-make,install_final-make)
$(call gen_uninstall_rules,final-make,uninstall_final-make)
$(call gen_check_rules,final-make,check_final-make)
$(call gen_dir_rules,final-make)
