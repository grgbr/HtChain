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
GDB, the GNU Project debugger, allows you to see what is going on inside
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

# Patches:
# * gdb-12.1-000-fix_ctf_test_cases.patch: fix testsuite CTF debug support
#   see bug 29468 https://sourceware.org/bugzilla/show_bug.cgi?id=29468
#   patch from commit https://sourceware.org/git/?p=binutils-gdb.git;a=commit;h=908a926ec4ecd48571aafb560d97b927b6f94b5e
# * gdb-12.1-001-add_kfail_longjmp_test_cases.patch: fix testsuite when libc has no longjmp probes
#   see bug 26967 https://sourceware.org/bugzilla/show_bug.cgi?id=26967
#   patch from (and modified) commit https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=gdb/testsuite/gdb.base/longjmp.exp;h=0f78304a14a2f0afeb4a1815dceb3388f6852e9c;hb=b5e7cd5cd3d1f90d0e7e58679a0782816bd5434f
define xtract_gdb
$(call rmrf,$(srcdir)/gdb)
$(call untar,$(srcdir)/gdb,\
             $(FETCHDIR)/$(gdb_dist_name),\
             --strip-components=1)
cd $(srcdir)/gdb && \
patch -p1 < $(PATCHDIR)/gdb-12.1-000-fix_ctf_test_cases.patch
cd $(srcdir)/gdb && \
patch -p1 < $(PATCHDIR)/gdb-12.1-001-add_kfail_longjmp_test_cases.patch
endef
$(call gen_xtract_rules,gdb,xtract_gdb)

$(call gen_dir_rules,gdb)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define gdb_config_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH='$(stagedir)/bin:$(PATH)' \
    $(srcdir)/gdb/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional make arguments
#
# Give make a HOME enviroment variable so that guile interpreter / compiler may
# generate files into build directory according to its needs without polluting
# user's HOME (compile cache is usually located under
# $XDG_CACHE_HOME/guile/ccache).
# See https://www.gnu.org/software/guile/manual/html_node/Compilation.html for
# more informations.
#
# Also enforce pkg-config tool to use thanks to PKG_CONFIG since internal
# <gdb>/gdb/configure script run at build time ignores our PKG_CONFIG setting
# given to the top-level configure script.
define gdb_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all \
         HOME='$(builddir)/$(strip $(1))/.home' \
         PKG_CONFIG='$(stage_pkg-config)' \
         PATH='$(stagedir)/bin:$(PATH)' \
         $(2) \
         $(verbose)
endef

# $(1): targets base name / module name
define gdb_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         HOME='$(builddir)/$(strip $(1))/.home' \
         PKG_CONFIG='$(stage_pkg-config)' \
         PATH='$(stagedir)/bin:$(PATH)' \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
# $(3): optional make arguments
#
# Give make a HOME enviroment variable so that guile interpreter / compiler may
# generate files into build directory according to its needs without polluting
# user's HOME (compile cache is usually located under
# $XDG_CACHE_HOME/guile/ccache).
# See https://www.gnu.org/software/guile/manual/html_node/Compilation.html for
# more informations.
define gdb_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         HOME='$(builddir)/$(strip $(1))/.home' \
         PKG_CONFIG='$(stage_pkg-config)' \
         PATH='$(stagedir)/bin:$(PATH)' \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(3) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define gdb_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          HOME='$(builddir)/$(strip $(1))/.home' \
          PKG_CONFIG='$(stage_pkg-config)' \
          PATH='$(stagedir)/bin:$(PATH)' \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Testing GDB wiki: https://sourceware.org/gdb/wiki/TestingGDB
# See also <gdb_src_dir>/gdb/testsuite/README
#
# Testsuite log located here: <gdb_build_dir>/gdb/testsuite/gdb.log
#
# To run a particular test, set RUNTESTFLAGS make variable from
# <gdb_build_dir>/gdb/testsuite like so:
#     make check RUNTESTFLAGS='GDB=$(stagedir)/bin/gdb <test_path>.exp
# For example, to run the CTF constant value test cases:
#     make check \
#          RUNTESTFLAGS='GDB=$(stagedir)/bin/gdb gdb.base/ctf-constvars.exp'
#
# Skip gdb.base/valgrind*.exp since requiring a glibc with debug symbols
#
# TODO:
# =====
# Review the following failing tests (which have been disabled):
# * gdb.python/py-breakpoint.exp
# * gdb.cp/no-dmgl-verbose.exp
# * gdb.reverse/finish-precsave.exp
# * gdb.opt/clobbered-registers-O2.exp
# * gdb.mi/mi-reverse.exp
# * gdb.mi/mi-breakpoint-multiple-locations.exp
# * gdb.gdb/unittest.exp
# * gdb.compile/compile-cplus-method.e
# * gdb.compile/compile-cplus-nested.exp
# * gdb.compile/compile-cplus-virtual.exp
# * gdb.compile/compile-cplus.exp
# * gdb.base/vla-struct-fields.exp
# Head to https://sourceware.org/bugzilla to get informations about open gdb
# issues !!
gdb_skipped_tests := gdb.base/valgrind-bt.exp \
                     gdb.base/valgrind-disp-step.exp \
                     gdb.base/valgrind-infcall.exp \
                     \
                     gdb.python/py-breakpoint.exp \
                     gdb.cp/no-dmgl-verbose.exp \
                     gdb.reverse/finish-precsave.exp \
                     gdb.opt/clobbered-registers-O2.exp \
                     gdb.mi/mi-reverse.exp \
                     gdb.mi/mi-breakpoint-multiple-locations.exp \
                     gdb.gdb/unittest.exp \
                     gdb.compile/compile-cplus-method.exp \
                     gdb.compile/compile-cplus-nested.exp \
                     gdb.compile/compile-cplus-virtual.exp \
                     gdb.compile/compile-cplus.exp \
                     gdb.base/vla-struct-fields.exp

define gdb_check_cmds
+env PATH='$(stagedir)/bin:$(PATH)' \
     LD_LIBRARY_PATH='$(stage_lib_path)' \
     HOME='$(builddir)/$(strip $(1))/.home' \
     $(MAKE) --directory $(builddir)/$(strip $(1))/gdb/testsuite \
             check \
             RUNTESTFLAGS='GDB=$(stagedir)/bin/gdb \
                           --ignore "$(notdir $(gdb_skipped_tests))"'
endef

# Note how pkg-config is given to --with-guile option: this is expected (see
# --help option to <gdb>/gdb/configure script).
gdb_common_config_args := --enable-silent-rules \
                          --with-pkgversion='$(pkgvers)' \
                          --with-bugurl='$(pkgurl)' \
                          --enable-plugins \
                          --disable-gdbtk \
                          --enable-threading \
                          --enable-64-bit-bfd \
                          --enable-source-highlight \
                          --enable-tui \
                          --with-curses \
                          --with-system-readline \
                          --with-system-zlib \
                          --with-expat \
                          --with-lzma \
                          --with-debuginfod \
                          --with-libgmp-prefix='$(stagedir)' \
                          --with-mpfr-prefix='$(stagedir)' \
                          --with-libipt-prefix='$(stagedir)' \
                          --with-libxxhash-prefix='$(stagedir)' \
                          --with-babeltrace-prefix='$(stagedir)' \
                          --with-python='$(stage_python)' \
                          --with-guile='$(stage_pkg-config)' \
                          --enable-unit-tests=yes \
                          --with-gnu-ld=yes \
                          --with-tcl \
                          --without-x \
                          --disable-assert

################################################################################
# Staging definitions
################################################################################

gdb_stage_config_args := $(gdb_common_config_args) \
                         --disable-nls \
                         MAKEINFO='/bin/true' \
                         $(stage_config_flags)

$(call gen_deps,stage-gdb,stage-zlib \
                          stage-python \
                          stage-guile \
                          stage-tcl \
                          stage-flex \
                          stage-libipt \
                          stage-libxxhash \
                          stage-source-highlight \
                          stage-expect \
                          stage-babeltrace)
$(call gen_check_deps,stage-gdb,stage-dejagnu)

config_stage-gdb       = $(call gdb_config_cmds,stage-gdb,\
                                                $(stagedir),\
                                                $(gdb_stage_config_args))
define build_stage-gdb
$(call gdb_build_cmds,stage-gdb,MAKEINFO='/bin/true')
endef

clean_stage-gdb        = $(call gdb_clean_cmds,stage-gdb)

define install_stage-gdb
$(call gdb_install_cmds,stage-gdb,,MAKEINFO='/bin/true')
endef

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

gdb_final_config_args := $(gdb_common_config_args) \
                         --enable-nls \
                         --disable-rpath \
                         $(final_config_flags)

$(call gen_deps,final-gdb,stage-zlib \
                          stage-python \
                          stage-guile \
                          stage-tcl \
                          stage-flex \
                          stage-libipt \
                          stage-libxxhash \
                          stage-source-highlight \
                          stage-expect \
                          stage-babeltrace)
$(call gen_check_deps,final-gdb,stage-dejagnu)


config_final-gdb       = $(call gdb_config_cmds,final-gdb,\
                                                $(PREFIX),\
                                                $(gdb_final_config_args))
# LD_LIBRARY_PATH add path to staging lib for conftest execution in
# sub-directory
build_final-gdb        = $(call gdb_build_cmds,final-gdb,\
                                            LD_LIBRARY_PATH='$(stage_lib_path)')
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
