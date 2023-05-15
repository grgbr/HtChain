################################################################################
# libtool modules
#
# Remove -DNDEBUG compile flags to make the whole testsuite pass. At least,
# tests 113 (`syntax of .la files') and 115 (`SList functionality') will fail
# otherwise
################################################################################

libtool_dist_url  := https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
libtool_dist_sum  := 47f4c6de40927254ff9ba452612c0702aea6f4edc7e797f0966c8c6bf0340d533598976cdba17f0bdc64545572e71cd319bbb587aa5f47cd2e7c1d96f873a3da
libtool_dist_name := $(notdir $(libtool_dist_url))
libtool_vers      := $(patsubst libtool-%.tar.xz,%,$(libtool_dist_name))
libtool_brief     := Generic library support script
libtool_home      := https://www.gnu.org/software/libtool/

define libtool_desc
This is GNU libtool, a generic library support script. Libtool hides the
complexity of generating special library types (such as shared libraries) behind
a consistent interface.  To use libtool, add the new generic library building
commands to your ``Makefile``, ``Makefile.in``, or ``Makefile.am``.  See the
documentation for details.  Libtool supports building static libraries on all
platforms.
endef

define fetch_libtool_dist
$(call download_csum,$(libtool_dist_url),\
                     $(libtool_dist_name),\
                     $(libtool_dist_sum))
endef
$(call gen_fetch_rules,libtool,libtool_dist_name,fetch_libtool_dist)

define xtract_libtool
$(call rmrf,$(srcdir)/libtool)
$(call untar,$(srcdir)/libtool,\
             $(FETCHDIR)/$(libtool_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,libtool,xtract_libtool)

$(call gen_dir_rules,libtool)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define libtool_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/libtool/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define libtool_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define libtool_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(strip $(3))') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define libtool_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' $(2)
endef

libtool_common_config_args := --enable-silent-rules \
                              --enable-ltdl-install

################################################################################
# Staging definitions
################################################################################

libtool_stage_config_args := $(libtool_common_config_args) \
                             $(call stage_config_flags,-DNDEBUG%)

$(call gen_deps,stage-libtool,stage-automake stage-m4)

config_stage-libtool    = $(call libtool_config_cmds,\
                                 stage-libtool,\
                                 $(stagedir),\
                                 $(libtool_stage_config_args))

define build_stage-libtool
+$(MAKE) --directory $(builddir)/stage-libtool \
         all \
         M4="$(stage_m4)" \
         $(verbose)
endef

clean_stage-libtool     = $(call libtool_clean_cmds,stage-libtool)

define install_stage-libtool
+$(MAKE) --directory $(builddir)/stage-libtool \
         install \
         $(verbose)
endef

uninstall_stage-libtool = $(call libtool_uninstall_cmds,\
                                 stage-libtool,\
                                 $(stagedir))
check_stage-libtool     = $(call libtool_check_cmds,stage-libtool)

$(call gen_config_rules_with_dep,stage-libtool,libtool,config_stage-libtool)
$(call gen_clobber_rules,stage-libtool)
$(call gen_build_rules,stage-libtool,build_stage-libtool)
$(call gen_clean_rules,stage-libtool,clean_stage-libtool)
$(call gen_install_rules,stage-libtool,install_stage-libtool)
$(call gen_uninstall_rules,stage-libtool,uninstall_stage-libtool)
$(call gen_check_rules,stage-libtool,check_stage-libtool)
$(call gen_dir_rules,stage-libtool)

################################################################################
# Final definitions
################################################################################

libtool_final_config_args := $(libtool_common_config_args) \
                             $(call final_config_flags,-DNDEBUG% $(rpath_flags))

$(call gen_deps,final-libtool,stage-automake stage-m4 stage-libtool)

config_final-libtool    = $(call libtool_config_cmds,\
                                 final-libtool,\
                                 $(PREFIX),\
                                 $(libtool_final_config_args))
# As configure script uses CC and CFLAGS passed as argument to infer default
# libtool configuration bits, we need to:
# * replace all references to $(stagedir) by references to prefix directory
#   within libtool script
# * replace default LTCFLAGS content with standard CFLAGS
# libtool-check is clone of libtool installed but we no change the htchain path.
# We need it for test.
define build_final-libtool
+$(MAKE) --directory $(builddir)/final-libtool \
         all \
         M4="$(stage_m4)" \
         $(verbose)
cp $(builddir)/final-libtool/libtool \
   $(builddir)/final-libtool/libtool-check
sed -i \
    -e 's;LTCFLAGS=.*;LTCFLAGS="-g -O2";' \
    $(builddir)/final-libtool/libtool-check
sed -i \
    -e 's;$(stagedir);$(PREFIX);g' \
    -e 's;LTCFLAGS=.*;LTCFLAGS="-g -O2";' \
    $(builddir)/final-libtool/libtool
endef

clean_final-libtool     = $(call libtool_clean_cmds,final-libtool)

define install_final-libtool
+$(MAKE) --directory $(builddir)/final-libtool \
         install \
         LIBTOOL='$(stage_libtool)' \
         DESTDIR='$(finaldir)' \
         $(verbose)
endef

uninstall_final-libtool = $(call libtool_uninstall_cmds,\
                                 final-libtool,\
                                 $(PREFIX),\
                                 $(finaldir))
check_final-libtool     = $(call libtool_check_cmds,final-libtool,\
    LIBTOOL='$(builddir)/final-libtool/libtool-check' \
    TESTSUITEFLAGS="LIBTOOL='$(builddir)/final-libtool/libtool-check'")

$(call gen_config_rules_with_dep,final-libtool,libtool,config_final-libtool)
$(call gen_clobber_rules,final-libtool)
$(call gen_build_rules,final-libtool,build_final-libtool)
$(call gen_clean_rules,final-libtool,clean_final-libtool)
$(call gen_install_rules,final-libtool,install_final-libtool)
$(call gen_uninstall_rules,final-libtool,uninstall_final-libtool)
$(call gen_check_rules,final-libtool,check_final-libtool)
$(call gen_dir_rules,final-libtool)
