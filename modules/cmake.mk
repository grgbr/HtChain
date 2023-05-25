################################################################################
# isl modules
################################################################################

cmake_dist_url  := https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1.tar.gz
cmake_dist_sum  := 94893f888c0cbfc58e54a0bd65d6c0697fe4a0e95c678b7cb35e7dc8854d57eb360bfc952750f97983348817f847f6df85903f21a5857b1a3880b2a7eb6cc029
cmake_dist_name := $(notdir $(cmake_dist_url))
cmake_vers      := $(patsubst cmake-%.tar.gz,%,$(cmake_dist_name))
cmake_brief     := Cross-platform, open-source make system
cmake_home      := https://cmake.org/

define cmake_desc
CMake is used to control the software compilation process using simple platform
and compiler independent configuration files. CMake generates native makefiles
and workspaces that can be used in the compiler environment of your choice.
CMake is quite sophisticated: it is possible to support complex environments
requiring system configuration, pre-processor generation, code generation, and
template instantiation.

CMake was developed by Kitware as part of the NLM Insight Segmentation and
Registration Toolkit project. The ASCI VIEWS project also provided support in
the context of their parallel computation environment. Other sponsors include
the Insight, VTK, and VXL open source software communities.
endef

define fetch_cmake_dist
$(call download_csum,$(cmake_dist_url),\
                     $(cmake_dist_name),\
                     $(cmake_dist_sum))
endef
$(call gen_fetch_rules,cmake,cmake_dist_name,fetch_cmake_dist)

define xtract_cmake
$(call rmrf,$(srcdir)/cmake)
$(call untar,$(srcdir)/cmake,\
             $(FETCHDIR)/$(cmake_dist_name),\
             --strip-components=1)
cd $(srcdir)/cmake && \
	patch -p1 < $(PATCHDIR)/cmake-3.23.1-000-fix_sphinx_pdf_path.patch
cd $(srcdir)/cmake && \
	patch -p1 < $(PATCHDIR)/cmake-3.23.1-001-fix_sphinx_share_paths.patch
cd $(srcdir)/cmake && \
	patch -p1 < $(PATCHDIR)/cmake-3.23.1-002-fix_test_git_submodule_protocol_file_allow.patch
cd $(srcdir)/cmake && \
	patch -p1 < $(PATCHDIR)/cmake-3.23.1-003-fix_test_find_boost.patch
endef
$(call gen_xtract_rules,cmake,xtract_cmake)

$(call gen_dir_rules,cmake)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
#
# bootstrap relies upon a working libuv (and others), that's why we must point
# LD_LIBRARY_PATH to staging area to complete final target configuration...
define cmake_config_cmds
+cd $(builddir)/$(strip $(1)) && \
 env PATH="$(stagedir)/bin:$(PATH)" \
     LD_LIBRARY_PATH="$(stage_lib_path)" \
 $(srcdir)/cmake/bootstrap --prefix="$(strip $(2))" \
                           --datadir="/share/cmake" \
                           --docdir="/share/doc/cmake" \
                           --mandir="/share/man" \
                           $(if $(V),--verbose) $(verbose) \
                           $(3)
endef

# $(1): targets base name / module name
define cmake_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         $(verbose)
endef

# $(1): targets base name / module name
define cmake_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define cmake_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define cmake_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          LD_LIBRARY_PATH="$(stage_lib_path)" \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Content of ARGS make variable is given to ctest (see ctest --help)
# To select a particular test give ARGS the additional option:
#     --tests-regex <test_name_regex>
# As an example, run the RunCMake.CMP0019 test case use the following:
#     ARGS="--verbose --stop-on-failure --output-on-failure --tests-regex RunCMake.CMP0019"
#
# Warning:
# --------
# Running the test target from a parallel parent make will lead to unexpected
# failure.
# Instead, disable parallel make using '--jobs 1' option and explicitly
# request ctest to run tests in parallel by giving ARGS variable the '-j$(JOBS)'
# option (ctest is run internally by the test target).
# See https://gitlab.kitware.com/cmake/cmake/issues/17165 for more infos
#
# Moreover, running the test target from a terminal supporting colors fools the
# regex matching logic of several tests. Disable color support by giving the
# check target the following make variables:
#     CLICOLOR=0 CLICOLOR_FORCE=0
# See https://gitlab.kitware.com/cmake/cmake/-/issues/22579
# CC: force cmake use gcc builded in stage dir instead of platform clang
# 
# Exclude ExternalProject test because GIT_SUBMODULES subtest use file as URI
# but transport 'file' not allowed by default.
define cmake_check_cmds
+env PATH="$(stagedir)/bin:$(PATH)" \
     LD_LIBRARY_PATH="$(stage_lib_path)" \
     CC='$(stage_cc)' \
     CXX='$(stage_cxx)' \
 $(MAKE) --jobs 1 \
         --directory $(builddir)/$(strip $(1)) \
         test \
         CLICOLOR=0 CLICOLOR_FORCE=0 \
         ARGS="-j$(JOBS) --output-on-failure -E ExternalProject"
endef

cmake_common_config_args := --datadir="/share/cmake" \
                            --docdir="/share/doc/cmake" \
                            --mandir="/share/man" \
                            --system-curl \
                            --system-expat \
                            --system-jsoncpp \
                            --bootstrap-system-jsoncpp \
                            --system-zlib \
                            --system-bzip2 \
                            --system-liblzma \
                            --system-zstd \
                            --system-libarchive \
                            --system-librhash \
                            --bootstrap-system-librhash \
                            --system-libuv \
                            --bootstrap-system-libuv \
                            --no-qt-gui

################################################################################
# Staging definitions
################################################################################

cmake_stage_config_args := $(cmake_common_config_args) \
                           CC='$(stage_cc)' \
                           CXX='$(stage_cxx)' \
                           CFLAGS='$(stage_cflags)' \
                           CXXFLAGS='$(stage_cxxflags)' \
                           LDFLAGS='$(stage_ldflags)'

$(call gen_deps,stage-cmake,stage-expat \
                            stage-jsoncpp \
                            stage-zlib \
                            stage-bzip2 \
                            stage-xz-utils \
                            stage-zstd \
                            stage-libarchive \
                            stage-rhash \
                            stage-libuv \
                            stage-curl)

config_stage-cmake       = $(call cmake_config_cmds,stage-cmake,\
                                                    $(stagedir),\
                                                    $(cmake_stage_config_args))
build_stage-cmake        = $(call cmake_build_cmds,stage-cmake)
clean_stage-cmake        = $(call cmake_clean_cmds,stage-cmake)
install_stage-cmake      = $(call cmake_install_cmds,stage-cmake)
uninstall_stage-cmake    = $(call cmake_uninstall_cmds,stage-cmake,$(stagedir))
check_stage-cmake        = $(call cmake_check_cmds,stage-cmake)

$(call gen_config_rules_with_dep,stage-cmake,cmake,config_stage-cmake)
$(call gen_clobber_rules,stage-cmake)
$(call gen_build_rules,stage-cmake,build_stage-cmake)
$(call gen_clean_rules,stage-cmake,clean_stage-cmake)
$(call gen_install_rules,stage-cmake,install_stage-cmake)
$(call gen_uninstall_rules,stage-cmake,uninstall_stage-cmake)
$(call gen_check_rules,stage-cmake,check_stage-cmake)
$(call gen_dir_rules,stage-cmake)

################################################################################
# Final definitions
################################################################################

# DCMAKE_SYSTEM_PREFIX_PATH="$(stagedir)" is required to instruct cmake
# bootstrap where to find the librhash package (through find_package() cmake
# macro).
cmake_final_config_args := $(cmake_common_config_args) \
                           --sphinx-info \
                           --sphinx-man \
                           --sphinx-html \
                           --sphinx-latexpdf \
                           CC='$(stage_cc)' \
                           CXX='$(stage_cxx)' \
                           CFLAGS='$(final_cflags)' \
                           CXXFLAGS='$(final_cxxflags)' \
                           LDFLAGS='$(final_ldflags)' \
                           -- \
                           -DCMAKE_SYSTEM_PREFIX_PATH="$(stagedir)"

$(call gen_deps,final-cmake,stage-expat \
                            stage-jsoncpp \
                            stage-zlib \
                            stage-bzip2 \
                            stage-xz-utils \
                            stage-zstd \
                            stage-libarchive \
                            stage-rhash \
                            stage-libuv \
                            stage-sphinx \
                            stage-texinfo \
                            stage-curl)

config_final-cmake       = $(call cmake_config_cmds,final-cmake,\
                                                    $(PREFIX),\
                                                    $(cmake_final_config_args))
build_final-cmake        = $(call cmake_build_cmds,final-cmake)
clean_final-cmake        = $(call cmake_clean_cmds,final-cmake)
install_final-cmake      = $(call cmake_install_cmds,final-cmake,$(finaldir))
uninstall_final-cmake    = $(call cmake_uninstall_cmds,final-cmake,\
                                                       $(PREFIX),\
                                                       $(finaldir))
check_final-cmake        = $(call cmake_check_cmds,final-cmake)

$(call gen_config_rules_with_dep,final-cmake,cmake,config_final-cmake)
$(call gen_clobber_rules,final-cmake)
$(call gen_build_rules,final-cmake,build_final-cmake)
$(call gen_clean_rules,final-cmake,clean_final-cmake)
$(call gen_install_rules,final-cmake,install_final-cmake)
$(call gen_uninstall_rules,final-cmake,uninstall_final-cmake)
$(call gen_check_rules,final-cmake,check_final-cmake)
$(call gen_dir_rules,final-cmake)
