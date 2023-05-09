################################################################################
# meson modules
################################################################################

meson_dist_url  := https://files.pythonhosted.org/packages/83/40/c0ea8d3072441403aa30d91b900051a961e0f6d58f702c0ec9ca812c8737/meson-1.0.0.tar.gz
meson_dist_sum  := 9b1195cfe856c1aa51bc79f6eb4d0f94925bb02d0a9fbd68a6a6ced6e5c252b09b22d9aac812640687e49b8d64a313ce48d0a69a3bf83ea8ffb8c9dab559fc23
meson_dist_name := $(notdir $(meson_dist_url))
meson_vers      := $(patsubst meson-%.tar.gz,%,$(meson_dist_name))
meson_brief     := High-productivity build system
meson_home      := https://mesonbuild.com

define meson_desc
Meson is a build system designed to increase programmer productivity. It does
this by providing a fast, simple and easy to use interface for modern software
development tools and practices.
endef

define fetch_meson_dist
$(call download_csum,$(meson_dist_url),\
                     $(FETCHDIR)/$(meson_dist_name),\
                     $(meson_dist_sum))
endef
$(call gen_fetch_rules,meson,meson_dist_name,fetch_meson_dist)

define xtract_meson
$(call rmrf,$(srcdir)/meson)
$(call untar,$(srcdir)/meson,\
             $(FETCHDIR)/$(meson_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,meson,xtract_meson)

$(call gen_dir_rules,meson)

meson_shebang_fixups = bin/meson \
                       $(addprefix $(python_site_path_comp)/,\
                                   mesonbuild/scripts/cmake_run_ctgt.py \
                                   mesonbuild/rewriter.py)

define meson_run_tests
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    $(call stage_config_flags,%) \
$(stage_python) $(2)
endef

# $(1): targets base name / module name
#
# Disabled tests:
# * qt and sdl2 since not supported / installed
# * "platform-linux/13 cmake dependency" run_project_tests.py test since
#   flaky: see https://github.com/mesonbuild/meson/issues/10104
define meson_check_cmds
$(call mkdir,$(builddir)/$(strip $(1))/.home)
$(call meson_run_tests,$(1),run_meson_command_tests.py)
$(call meson_run_tests,$(1),\
                       run_unittests.py \
                       --verbose \
                       --backend=ninja \
                       -k='not (test_qtdependency_pkgconfig_detection or \
                                test_qt5dependency_qmake_detection or \
                                test_sdl2_notfound_dependency)')
$(call meson_run_tests,$(1),\
                       run_project_tests.py \
                       --backend=ninja \
                       --only cmake \
                              common \
                              native \
                              warning-meson \
                              failing-meson \
                              failing-build \
                              failing-test \
                              keyval \
                              "platform-linux/1 pkg-config" \
                              "platform-linux/2 external library" \
                              "platform-linux/3 linker script" \
                              "platform-linux/4 extdep static lib" \
                              "platform-linux/5 dependency versions" \
                              "platform-linux/6 subdir include order" \
                              "platform-linux/7 library versions" \
                              "platform-linux/8 subproject library install" \
                              "platform-linux/9 compiler checks with dependencies" \
                              "platform-linux/10 large file support" \
                              "platform-linux/11 runpath rpath ldlibrarypath" \
                              "platform-linux/12 subprojects in subprojects" \
                              "platform-linux/14 static dynamic linkage" \
                              "platform-linux/15 ld binary" \
                              python3 \
                              "frameworks/6 gettext" \
                              "frameworks/8 flex" \
                              "frameworks/14 doxygen" \
                              "frameworks/31 curses")
endef

################################################################################
# Staging definitions
################################################################################

define install_stage-meson
$(call python_module_install_cmds,stage-meson,$(stagedir))
$(call fixup_shebang,\
       $(addprefix $(stagedir)/,$(meson_shebang_fixups)),\
       $(stagedir)/bin/python)
endef

check_stage-meson = $(call meson_check_cmds,stage-meson)

$(call gen_deps,stage-meson,stage-ninja stage-wheel)
$(call gen_check_deps,stage-meson,\
                      stage-pytest-xdist \
                      stage-cmake \
                      stage-doxygen \
                      stage-flex \
                      stage-gettext \
                      stage-glib)
$(call gen_python_module_rules,stage-meson,meson,$(stagedir))

################################################################################
# Final definitions
################################################################################

define install_final-meson
$(call python_module_install_cmds,final-meson,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(meson_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

check_final-meson = $(call meson_check_cmds,final-meson)

$(call gen_deps,final-meson,stage-ninja stage-wheel)
$(call gen_check_deps,final-meson,\
                      stage-pytest-xdist \
                      stage-cmake \
                      stage-doxygen \
                      stage-flex \
                      stage-gettext \
                      stage-glib)
$(call gen_python_module_rules,final-meson,meson,$(PREFIX),$(finaldir))
