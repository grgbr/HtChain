################################################################################
# gdb modules
#
# Read the <gdb>/gdb/README file for in-depth explanations about how to build
# gdb !
################################################################################

gdb_dist_url  := https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.xz
gdb_dist_sum  := 425568d2e84672177d0fb87b1ad7daafdde097648d605e30cf0656970f66adc6a82ca2d83375ea4be583e9683a340e5bfdf5819668ddf66728200141ae50ff2d
gdb_dist_name := $(notdir $(gdb_dist_url))
gdb_vers      := $(patsubst gdb-%.tar.xz,%,$(gdb_dist_name))
gdb_brief     := GNU Debugger
gdb_home      := https://www.sourceware.org/gdb/

define gdb_desc
GDB, the GNU Project debugger, allows you to see what is going on `inside\'
another program while it executes -- or what another program was doing at the
moment it crashed.

GDB can do four main kinds of things (plus other things in support of these) to
help you catch bugs in the act:

* start your program, specifying anything that might affect its behavior ;
* make your program stop on specified conditions ;
* examine what has happened, when your program has stopped ;
* change things in your program, so you can experiment with correcting the
  effects of one bug and go on to learn about another.

Currently, gdb supports C, C++, D, Objective-C, Fortran, Java, OpenCL C, Pascal,
assembly, Modula-2, Go, and Ada. A must-have for any serious programmer.

Those programs might be executing on the same machine as GDB (native), on
another machine (remote), or on a simulator. GDB can run on most popular UNIX
and Microsoft Windows variants, as well as on Mac OS X.

endef

define fetch_gdb_dist
$(call download_csum,$(gdb_dist_url),\
                     $(FETCHDIR)/$(gdb_dist_name),\
                     $(gdb_dist_sum))
endef
$(call gen_fetch_rules,gdb,gdb_dist_name,fetch_gdb_dist)

define xtract_gdb
$(call rmrf,$(srcdir)/gdb)
$(call untar,$(srcdir)/gdb,\
             $(FETCHDIR)/$(gdb_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,gdb,xtract_gdb)

$(call gen_dir_rules,gdb)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gdb_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/gdb/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
#
# Give make an LD_LIBRARY_PATH since running a temporary build-side gdb
# requiring various libraries (such as libtextstyle.so) which are not yet
# definitely installed at final stage.
define gdb_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         LD_LIBRARY_PATH='$(_stage_lib_path)' \
         $(verbose)
endef

# $(1): targets base name / module name
define gdb_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
	clean \
	$(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
#
# Give make an LD_LIBRARY_PATH since running a temporary build-side gdb
# requiring various libraries (such as libtextstyle.so) which are not yet
# definitely installed at final stage.
define gdb_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         LD_LIBRARY_PATH='$(_stage_lib_path)' \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gdb_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define gdb_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)'
endef

gdb_common_config_args := --enable-silent-rules \
                          --enable-ld=yes \
                          --enable-gprofng=yes \
                            --enable-threads=posix \
                            --disable-assert

################################################################################
# Staging definitions
################################################################################

gdb_stage_config_args := $(gdb_common_config_args) \
                           --disable-nls \
                           MISSING='true' \
                           $(filter-out FLEX=% LEX=%,$(stage_config_flags))

$(call gen_deps,stage-gdb,stage-gcc stage-m4)
$(call gen_check_deps,stage-gdb,stage-perl)

config_stage-gdb       = $(call gdb_config_cmds,stage-gdb,\
                                                    $(stagedir),\
                                                    $(gdb_stage_config_args))
build_stage-gdb        = $(call gdb_build_cmds,stage-gdb)
clean_stage-gdb        = $(call gdb_clean_cmds,stage-gdb)
install_stage-gdb      = $(call gdb_install_cmds,stage-gdb)
uninstall_stage-gdb    = $(call gdb_uninstall_cmds,stage-gdb,$(stagedir))
check_stage-gdb        = $(call gdb_check_cmds,stage-gdb)

$(call gen_config_rules_with_dep,stage-gdb,gdb,config_stage-gdb)
$(call gen_clobber_rules,stage-gdb)
$(call gen_build_rules,stage-gdb,build_stage-gdb)
$(call gen_clean_rules,stage-gdb,clean_stage-gdb)
$(call gen_install_rules,stage-gdb,install_stage-gdb)
$(call gen_uninstall_rules,stage-gdb,uninstall_stage-gdb)
$(call gen_check_rules,stage-gdb,check_stage-gdb)
$(call gen_dir_rules,stage-gdb)

################################################################################
# Final definitions
################################################################################

# Disable RPATH at configure time to prevent from embedding $(stage_lib_path)
# into binary RPATH.
gdb_final_config_args := $(gdb_common_config_args) \
                           --enable-nls \
                           --disable-rpath \
                           $(final_config_flags)

$(call gen_deps,final-gdb,stage-gcc \
                            stage-m4 \
                            stage-flex \
                            stage-readline \
                            stage-gettext)
$(call gen_check_deps,final-gdb,stage-perl)

config_final-gdb       = $(call gdb_config_cmds,final-gdb,\
                                                    $(PREFIX),\
                                                    $(gdb_final_config_args))
build_final-gdb        = $(call gdb_build_cmds,final-gdb)
clean_final-gdb        = $(call gdb_clean_cmds,final-gdb)
install_final-gdb      = $(call gdb_install_cmds,final-gdb,$(finaldir))
uninstall_final-gdb    = $(call gdb_uninstall_cmds,final-gdb,\
                                                 $(PREFIX),\
                                                 $(finaldir))
check_final-gdb        = $(call gdb_check_cmds,final-gdb)

$(call gen_config_rules_with_dep,final-gdb,gdb,config_final-gdb)
$(call gen_clobber_rules,final-gdb)
$(call gen_build_rules,final-gdb,build_final-gdb)
$(call gen_clean_rules,final-gdb,clean_final-gdb)
$(call gen_install_rules,final-gdb,install_final-gdb)
$(call gen_uninstall_rules,final-gdb,uninstall_final-gdb)
$(call gen_check_rules,final-gdb,check_final-gdb)
$(call gen_dir_rules,final-gdb)
