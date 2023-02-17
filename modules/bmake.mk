################################################################################
# BSD make modules
################################################################################

bmake_dist_url  := https://www.crufty.net/ftp/pub/sjg/bmake-20220418.tar.gz
bmake_dist_sum  := 89fa5cb6e35ee1cd6a32acf291bda33b3a7272c4ef25d38412b8caa7e092210c8fa04a11d19d3c19b7e60dee2cf0a5049cf393be6e25b6e28bab2eea50e03204
bmake_dist_name := $(notdir $(bmake_dist_url))
bmake_vers      := $(patsubst bmake-%.tar.gz,%,$(bmake_dist_name))
bmake_brief     := NetBSD make
bmake_home      := http://www.crufty.net/help/sjg/bmake.html

define bmake_desc
``bmake`` is a program designed to simplify the maintenance of other programs.
Its input is a list of specifications as to the files upon which programs and
other files depend. ``mkdep``, a program to construct Makefile dependency lists,
is also included.

``bmake`` is a port of the NetBSD make tool.
endef

define fetch_bmake_dist
$(call download_csum,$(bmake_dist_url),\
                     $(FETCHDIR)/$(bmake_dist_name),\
                     $(bmake_dist_sum))
endef
$(call gen_fetch_rules,bmake,bmake_dist_name,fetch_bmake_dist)

define xtract_bmake
$(call rmrf,$(srcdir)/bmake)
$(call untar,$(srcdir)/bmake,\
             $(FETCHDIR)/$(bmake_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,bmake,xtract_bmake)

$(call gen_dir_rules,bmake)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define bmake_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/bmake/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define bmake_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) build $(verbose)
endef

# $(1): targets base name / module name
define bmake_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define bmake_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(CHMOD) u+w "$(strip $(3))$(strip $(2))/bin/bmake" $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define bmake_uninstall_cmds
$(call rmrf,$(strip $(3))$(strip $(2))/share/mk)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/cat1/bmake.1)
$(call rmf,$(strip $(3))$(strip $(2))/bin/bmake)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define bmake_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) test
endef

################################################################################
# Final definitions
################################################################################

bmake_final_config_args := $(call $(final_config_flags),$(rpath_flags))

$(call gen_deps,final-bmake,stage-gcc)

config_final-bmake       = $(call bmake_config_cmds,final-bmake,\
                                                    $(PREFIX),\
                                                    $(bmake_final_config_args))
build_final-bmake        = $(call bmake_build_cmds,final-bmake)
clean_final-bmake        = $(call bmake_clean_cmds,final-bmake)

final-bmake_shebang_fixups := share/mk/meta2deps.py

define install_final-bmake
$(call bmake_install_cmds,final-bmake,$(PREFIX),$(finaldir))
$(call fixup_shebang,$(addprefix $(finaldir)$(PREFIX)/,\
                                 $(final-bmake_shebang_fixups)),\
                     $(PREFIX)/bin/python)
endef

uninstall_final-bmake    = $(call bmake_uninstall_cmds,final-bmake,\
                                                       $(PREFIX),\
                                                       $(finaldir))
check_final-bmake        = $(call bmake_check_cmds,final-bmake)

$(call gen_config_rules_with_dep,final-bmake,bmake,config_final-bmake)
$(call gen_clobber_rules,final-bmake)
$(call gen_build_rules,final-bmake,build_final-bmake)
$(call gen_clean_rules,final-bmake,clean_final-bmake)
$(call gen_install_rules,final-bmake,install_final-bmake)
$(call gen_uninstall_rules,final-bmake,uninstall_final-bmake)
$(call gen_check_rules,final-bmake,check_final-bmake)
$(call gen_dir_rules,final-bmake)
