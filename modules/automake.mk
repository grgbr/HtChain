################################################################################
# autoconf modules
################################################################################

automake_dist_url   := https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz
automake_dist_sum   := 3084ae543aa3fb5a05104ffb2e66cfa9a53080f2343c44809707fd648516869511500dba50dae67ff10f92a1bf3b5a92b2a0fa01cda30adb69b9da03994d9d88
automake_dist_name  := $(notdir $(automake_dist_url))
automake_vers       := $(patsubst automake-%.tar.xz,%,$(automake_dist_name))
_automake_vers_toks := $(subst .,$(space),$(automake_vers))
automake_vers_maj   := $(word 1,$(_automake_vers_toks))
automake_vers_min   := $(word 2,$(_automake_vers_toks))
automake_brief      := Tool for generating GNU Standards-compliant Makefiles
automake_home       := https://www.gnu.org/software/automake/

define automake_desc
Automake is a tool for automatically generating :file:`Makefile.in` from
files called :file:`Makefile.am`.

The goal of Automake is to remove the burden of Makefile maintenance from the
back of the individual GNU maintainer (and put it on the back of the Automake
maintainer).

The :file:`Makefile.am` is basically a series of ``make`` macro definitions
(with rules being thrown in occasionally). The generated :file:`Makefile.in`
are compliant with the GNU Makefile standards.
endef

define fetch_automake_dist
$(call download_csum,$(automake_dist_url),\
                     $(automake_dist_name),\
                     $(automake_dist_sum))
endef
$(call gen_fetch_rules,automake,automake_dist_name,fetch_automake_dist)

define xtract_automake
$(call rmrf,$(srcdir)/automake)
$(call untar,$(srcdir)/automake,\
             $(FETCHDIR)/$(automake_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,automake,xtract_automake)

$(call gen_dir_rules,automake)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define automake_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/automake/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define automake_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         PATH="$(stagedir)/bin:$(PATH)" \
         $(verbose)
endef

# $(1): targets base name / module name
define automake_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define automake_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(call rmf,$(strip $(3))$(strip $(2))/bin/aclocal)
$(call slink,aclocal-$(automake_vers_maj).$(automake_vers_min),\
             $(strip $(3))$(strip $(2))/bin/aclocal)
$(call rmf,$(strip $(3))$(strip $(2))/bin/automake)
$(call slink,automake-$(automake_vers_maj).$(automake_vers_min),\
             $(strip $(3))$(strip $(2))/bin/automake)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
#
# Because, test result directories are created read-only, run a chmod command to
# make them read-write beforehand.
define automake_uninstall_cmds
$(CHMOD) --recursive u+rwx $(builddir)/$(strip $(1))
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define automake_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PERL="$(stage_perl)" \
         PATH="$(stagedir)/bin:$(PATH)"
endef

################################################################################
# Staging definitions
################################################################################

automake_stage_config_args := --enable-silent-rules \
                              $(stage_config_flags) \
                              PATH="$(stagedir)/bin:$(PATH)"

$(call gen_deps,stage-automake,stage-autoconf)
$(call gen_check_deps,stage-automake,stage-libtool stage-flex stage-dejagnu \
                                     stage-gettext stage-python stage-bison \
                                     stage-texinfo stage-help2man)

config_stage-automake       = $(call automake_config_cmds,\
                                     stage-automake,\
                                     $(stagedir),\
                                     $(automake_stage_config_args))
build_stage-automake        = $(call automake_build_cmds,stage-automake)
clean_stage-automake        = $(call automake_clean_cmds,stage-automake)
install_stage-automake      = $(call automake_install_cmds,stage-automake,\
                                                           $(stagedir))
uninstall_stage-automake    = $(call automake_uninstall_cmds,stage-automake,\
                                                             $(stagedir))
check_stage-automake        = $(call automake_check_cmds,stage-automake)

$(call gen_config_rules_with_dep,stage-automake,automake,config_stage-automake)
$(call gen_clobber_rules,stage-automake)
$(call gen_build_rules,stage-automake,build_stage-automake)
$(call gen_clean_rules,stage-automake,clean_stage-automake)
$(call gen_install_rules,stage-automake,install_stage-automake)
$(call gen_uninstall_rules,stage-automake,uninstall_stage-automake)
$(call gen_check_rules,stage-automake,check_stage-automake)
$(call gen_dir_rules,stage-automake)

################################################################################
# Final definitions
################################################################################

automake_final_config_args := --enable-silent-rules \
                              $(final_config_flags) \
                              ac_cv_path_PERL="$(stage_perl)"

$(call gen_deps,final-automake,stage-autoconf stage-help2man)
$(call gen_check_deps,final-automake,stage-libtool stage-flex stage-dejagnu \
                                     stage-gettext stage-python stage-bison \
                                     stage-texinfo)

config_final-automake    = $(call automake_config_cmds,\
                                  final-automake,\
                                  $(PREFIX),\
                                  $(automake_final_config_args))
build_final-automake     = $(call automake_build_cmds,final-automake)
clean_final-automake     = $(call automake_clean_cmds,final-automake)

final-automake_perl_fixups := bin/aclocal bin/automake

define install_final-automake
$(call automake_install_cmds,final-automake,$(PREFIX),$(finaldir))
$(call fixup_shebang,$(addprefix $(finaldir)$(PREFIX)/,\
                                 $(final-automake_perl_fixups)),\
                     $(PREFIX)/bin/perl)
endef

uninstall_final-automake = $(call automake_uninstall_cmds,\
                                  final-automake,\
                                  $(PREFIX),\
                                  $(finaldir))
check_final-automake     = $(call automake_check_cmds,final-automake)

$(call gen_config_rules_with_dep,final-automake,automake,config_final-automake)
$(call gen_clobber_rules,final-automake)
$(call gen_build_rules,final-automake,build_final-automake)
$(call gen_clean_rules,final-automake,clean_final-automake)
$(call gen_install_rules,final-automake,install_final-automake)
$(call gen_uninstall_rules,final-automake,uninstall_final-automake)
$(call gen_check_rules,final-automake,check_final-automake)
$(call gen_dir_rules,final-automake)
