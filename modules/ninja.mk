################################################################################
# ninja modules
################################################################################

ninja_dist_url  := https://github.com/ninja-build/ninja/archive/refs/tags/v1.10.2.tar.gz
ninja_dist_sum  := 895412ae1cbc83c656e92f282602a29300e08274e9dea0da4464202ae556e7a1ab03bec057f23da4756bbd91bd2d744cd7a64b336740fd2782bb4db5c3b7b496
ninja_vers      := $(patsubst v%.tar.gz,%,$(notdir $(ninja_dist_url)))
ninja_dist_name := ninja-$(ninja_vers).tar.gz
ninja_brief     := Small build system closest in spirit to Make
ninja_home      := https://ninja-build.org/

define ninja_desc
Ninja is yet another build system. It takes as input the interdependencies of
files (typically source code and output executables) and orchestrates building
them, quickly.

Ninja joins a sea of other build systems. Its distinguishing goal is to be fast.
It is born from the Chromium browser project, which has over 30,000 source files
and whose other build systems can take ten seconds to start building after
changing one file. Ninja is under a second.
endef

define fetch_ninja_dist
$(call download_csum,$(ninja_dist_url),\
                     $(FETCHDIR)/$(ninja_dist_name),\
                     $(ninja_dist_sum))
endef
$(call gen_fetch_rules,ninja,ninja_dist_name,fetch_ninja_dist)

define xtract_ninja
$(call rmrf,$(srcdir)/ninja)
$(call untar,$(srcdir)/ninja,\
             $(FETCHDIR)/$(ninja_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,ninja,xtract_ninja)

$(call gen_dir_rules,ninja)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define ninja_build_cmds
cd $(builddir)/$(strip $(1)) && \
env $(3) LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/python $(srcdir)/ninja/configure.py \
                       $(if $(V),--verbose) \
                       --bootstrap \
                       --with-python="$(strip $(2))/bin/python"
cd $(builddir)/$(strip $(1)) && \
env LD_LIBRARY_PATH="$(stage_lib_path)" ./ninja $(if $(V),--verbose) all
endef

# $(1): targets base name / module name
define ninja_clean_cmds
cd $(builddir)/$(strip $(1)) && \
env LD_LIBRARY_PATH="$(stage_lib_path)" ./ninja $(if $(V),--verbose) clean
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define ninja_install_cmds
$(INSTALL) --mode=755 --directory $(strip $(3))$(strip $(2))/bin $(verbose)
$(INSTALL) --mode=755 $(builddir)/$(strip $(1))/ninja \
                      $(strip $(3))$(strip $(2))/bin/ninja
endef

# $(1): build / install prefix
# $(2): optional install destination directory
define ninja_uninstall_cmds
$(call rmf,$(strip $(2))$(strip $(1))/bin/ninja)
$(call cleanup_empty_dirs,$(strip $(2))$(strip $(1)))
endef

# $(1): targets base name / module name
define ninja_check_cmds
cd $(builddir)/$(strip $(1)) && \
env LD_LIBRARY_PATH="$(stage_lib_path)" ./ninja_test
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-ninja,stage-python)

build_stage-ninja        = $(call ninja_build_cmds,stage-ninja,\
                                                   $(stagedir),\
                                                   $(stage_config_flags))
clean_stage-ninja        = $(call ninja_clean_cmds,stage-ninja)
install_stage-ninja      = $(call ninja_install_cmds,stage-ninja,$(stagedir))
uninstall_stage-ninja    = $(call ninja_uninstall_cmds,$(stagedir))
check_stage-ninja        = $(call ninja_check_cmds,stage-ninja)

$(call gen_config_rules_with_dep,stage-ninja,ninja)
$(call gen_clobber_rules,stage-ninja)
$(call gen_build_rules,stage-ninja,build_stage-ninja)
$(call gen_clean_rules,stage-ninja,clean_stage-ninja)
$(call gen_install_rules,stage-ninja,install_stage-ninja)
$(call gen_uninstall_rules,stage-ninja,uninstall_stage-ninja)
$(call gen_check_rules,stage-ninja,check_stage-ninja)
$(call gen_dir_rules,stage-ninja)

################################################################################
# Final definitions
################################################################################

ninja_final_config_args := $(ninja_common_args) \
                           $(final_config_flags)

$(call gen_deps,final-ninja,stage-python)

build_final-ninja        = $(call ninja_build_cmds,final-ninja,\
                                                   $(PREFIX),\
                                                   $(final_config_flags))
clean_final-ninja        = $(call ninja_clean_cmds,final-ninja)
install_final-ninja      = $(call ninja_install_cmds,final-ninja,\
                                                     $(PREFIX),\
                                                     $(finaldir))
uninstall_final-ninja    = $(call ninja_uninstall_cmds,$(PREFIX),\
                                                       $(finaldir))
check_final-ninja        = $(call ninja_check_cmds,final-ninja)

$(call gen_config_rules_with_dep,final-ninja,ninja)
$(call gen_clobber_rules,final-ninja)
$(call gen_build_rules,final-ninja,build_final-ninja)
$(call gen_clean_rules,final-ninja,clean_final-ninja)
$(call gen_install_rules,final-ninja,install_final-ninja)
$(call gen_uninstall_rules,final-ninja,uninstall_final-ninja)
$(call gen_check_rules,final-ninja,check_final-ninja)
$(call gen_dir_rules,final-ninja)
