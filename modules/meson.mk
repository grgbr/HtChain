# TODO:
# * depends on qt5 (for testing) ??
# * --disable-nls ? (stage vs final)
# * setup pkg-config properly (for testing also)
# * fix failing tests
# * hotdoc support ?
meson_dist_url  := https://files.pythonhosted.org/packages/83/40/c0ea8d3072441403aa30d91b900051a961e0f6d58f702c0ec9ca812c8737/meson-1.0.0.tar.gz
meson_dist_sum  := aa50a4ba4557c25e7d48446abfde857957dcdf58385fffbe670ba0e8efacce05
meson_dist_name := $(notdir $(meson_dist_url))

define fetch_meson_dist
$(call _download,$(meson_dist_url),$(FETCHDIR)/$(meson_dist_name).tmp)
cat $(FETCHDIR)/$(meson_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(meson_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(meson_dist_name).tmp,\
          $(FETCHDIR)/$(meson_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(meson_dist_name)'
endef
# As fetch_meson_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(meson_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,meson,meson_dist_name,fetch_meson_dist)

define xtract_meson
$(call rmrf,$(srcdir)/meson)
$(call untar,$(srcdir)/meson,\
             $(FETCHDIR)/$(meson_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,meson,xtract_meson)

$(call gen_dir_rules,meson)

define meson_run_tests
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    $(call stage_config_flags,%) \
$(stage_python) $(2)
endef

# $(1): targets base name / module name
#
# Disabled tests:
# * platform-linux/6 subdir include order: requires a glib2 development install
# * platform-linux/9 compiler checks with dependencies: requires a glib2
#                                                       development install
define meson_check_cmds
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
                              "platform-linux/7 library versions" \
                              "platform-linux/8 subproject library install" \
                              "platform-linux/10 large file support" \
                              "platform-linux/11 runpath rpath ldlibrarypath" \
                              "platform-linux/12 subprojects in subprojects" \
                              "platform-linux/13 cmake dependency" \
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

$(call gen_deps,stage-meson,stage-ninja stage-wheel)
$(call gen_check_deps,stage-meson,\
                      stage-pytest-xdist \
                      stage-cmake \
                      stage-doxygen \
                      stage-flex \
                      stage-gettext)

check_stage-meson = $(call meson_check_cmds,stage-meson)
$(call gen_python_module_rules,stage-meson,meson,$(stagedir),,check_stage-meson)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-meson,stage-ninja stage-wheel)
$(call gen_check_deps,final-meson,\
                      stage-pytest-xdist \
                      stage-cmake \
                      stage-doxygen \
                      stage-flex \
                      stage-gettext)

check_final-meson = $(call meson_check_cmds,final-meson)
$(call gen_python_module_rules,final-meson,\
                               meson,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-meson)
