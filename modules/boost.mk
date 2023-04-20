################################################################################
# boost modules
################################################################################

boost_dist_url  := https://boostorg.jfrog.io/artifactory/main/release/1.81.0/source/boost_1_81_0.tar.bz2
boost_dist_sum  := a04201e73da59f68fa02761b333c864a96ebaf268247b6b10cb19ed3d70ee9ad3da4c53123f2a7a4a9b9e1408793b51e1adbcc6fd09f60fecef3ca9522bb6b36
boost_dist_name := $(subst _,.,$(subst boost_,boost-,$(notdir $(boost_dist_url))))
boost_vers      := $(patsubst boost_%.tar.bz2,%,$(boost_dist_name))
boost_brief     := Boost C++ Libraries
boost_home      := https://www.boost.org/

define boost_desc
The Boost web site provides free, peer-reviewed, portable C++ source
libraries. The emphasis is on libraries which work well with the C++
Standard Library. One goal is to establish "existing practice" and
provide reference implementations so that the Boost libraries are
suitable for eventual standardization. Some of the libraries have
already been proposed for inclusion in the C++ Standards Committee\'s
upcoming C++ Standard Library Technical Report.
endef

define fetch_boost_dist
$(call download_csum,$(boost_dist_url),\
                     $(FETCHDIR)/$(boost_dist_name),\
                     $(boost_dist_sum))
endef
$(call gen_fetch_rules,boost,boost_dist_name,fetch_boost_dist)

define xtract_boost
$(call rmrf,$(srcdir)/boost)
$(call untar,$(srcdir)/boost,\
             $(FETCHDIR)/$(boost_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,boost,xtract_boost)

$(call gen_dir_rules,boost)

# For build and compile instructions, see:
# <boost>/more/getting_started/unix-variants.html
define boost_jam_config
using gcc
	:
	: $$CXX
	: <compileflags>\"$$CPPFLAGS\" <cflags>\"$$CFLAGS\" <cxxflags>\"$$CXXFLAGS\" <linkflags>\"$$LDFLAGS\"
	;
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): environment
# $(4): b2 arguments
define boost_config_cmds
$(RSYNC) --archive --delete $(srcdir)/boost/ $(builddir)/$(strip $(1))
cd $(builddir)/$(strip $(1)) && \
env $(3) sh -c '/bin/echo -e -n "$(subst $(newline),\n,$(boost_jam_config))"' > user-config.jam
cd $(builddir)/$(strip $(1)) && \
env $(3) ./bootstrap.sh --prefix='$(strip $(2))' \
                        $(4) \
                        $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): environment
# $(4): b2 arguments
define boost_build_cmds
cd $(builddir)/$(strip $(1))/ && \
env $(3) ./b2 -d$(if $(V),2,1) \
              -q \
              --user-config="$(builddir)/$(strip $(1))/user-config.jam" \
              --prefix='$(installdir)/$(strip $(1))' \
              $(4) \
              install \
              $(verbose)
endef

# $(1): targets base name / module name
define boost_clean_cmds
cd $(builddir)/$(strip $(1))/ && \
./b2 -d$(if $(V),2,1) \
     -q \
     --user-config="$(builddir)/$(strip $(1))/user-config.jam" \
     --clean \
     $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define boost_install_cmds
$(MKDIR) --parents --mode=755 $(strip $(3))$(strip $(2))
$(RSYNC) --archive \
         $(installdir)/$(strip $(1))/ \
         $(strip $(3))$(strip $(2)) \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define boost_uninstall_cmds
$(call uninstall_from_refdir,\
       $(installdir)/$(strip $(1)),\
       $(strip $(3))$(strip $(2)))
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
# $(2): make flags
#
# Building with -DNDEBUG makes some variables unused since wrapped into
# assertion call. As boost is building its testsuite with the -Werror flag
# given to gcc, this makes boost build process fail.
# Get rid of -DNDEBUG from compile / link flags.
define boost_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         check \
         PATH='$(stagedir)/bin:$(PATH)' \
         LD_LIBRARY_PATH='$(stage_lib_path)' \
         $(subst -DNDEBUG,,$(2))
endef

boost_common_config_args := --with-toolset=gcc \
                            --with-icu='$(stagedir)' \
                            --with-python='$(stage_python)'

# See <boost>/tools/build/src/tools/gcc.jam for available properties
boost_common_b2_args     := toolset=gcc \
                            variant=release \
                            threading=multi \
                            optimization=speed \
                            inlining=on \
                            profiling=off \
                            debug-symbols=on \
                            exception-handling=on \
                            rtti=on \
                            coverage=off \
                            lto=on \
                            stdlib=gnu11 \
                            local-visibility=hidden \
                            --build-type=minimal \
                            --layout=system \
                            --without-graph_parallel \
                            --without-mpi

################################################################################
# Staging definitions
################################################################################

boost_stage_config_env  := PATH="$(stagedir)/bin:$(PATH)" $(stage_config_flags)

$(call gen_deps,stage-boost,stage-zlib \
                            stage-bzip2 \
                            stage-pkg-config \
                            stage-zstd \
                            stage-icu4c \
                            stage-xz-utils \
                            stage-python)

config_stage-boost       = $(call boost_config_cmds,stage-boost,\
                                                    $(stagedir),\
                                                    $(boost_stage_config_env),\
                                                    $(boost_common_config_args))
build_stage-boost        = $(call boost_build_cmds,stage-boost,\
                                                   $(stagedir),\
                                                   $(boost_stage_config_env),\
                                                   $(boost_common_b2_args))
clean_stage-boost        = $(call boost_clean_cmds,stage-boost)
install_stage-boost      = $(call boost_install_cmds,stage-boost,$(stagedir))
uninstall_stage-boost    = $(call boost_uninstall_cmds,stage-boost,$(stagedir))
check_stage-boost        = $(call boost_check_cmds,stage-boost,\
                                                   $(stage_config_flags))

$(call gen_config_rules_with_dep,stage-boost,boost,config_stage-boost)
$(call gen_clobber_rules,stage-boost)
$(call gen_build_rules,stage-boost,build_stage-boost)
$(call gen_clean_rules,stage-boost,clean_stage-boost)
$(call gen_install_rules,stage-boost,install_stage-boost)
$(call gen_uninstall_rules,stage-boost,uninstall_stage-boost)
$(call gen_check_rules,stage-boost,check_stage-boost)
$(call gen_dir_rules,stage-boost)

################################################################################
# Final definitions
################################################################################

boost_final_config_env  := PATH="$(stagedir)/bin:$(PATH)" $(final_config_flags)

$(call gen_deps,final-boost,stage-zlib \
                            stage-bzip2 \
                            stage-pkg-config \
                            stage-zstd \
                            stage-icu4c \
                            stage-xz-utils \
                            stage-python)


config_final-boost       = $(call boost_config_cmds,final-boost,\
                                                    $(PREFIX),\
                                                    $(boost_final_config_env),\
                                                    $(boost_common_config_args))
build_final-boost        = $(call boost_build_cmds,final-boost,\
                                                   $(PREFIX),\
                                                   $(boost_final_config_env),\
                                                   $(boost_common_b2_args))
clean_final-boost        = $(call boost_clean_cmds,final-boost)
install_final-boost      = $(call boost_install_cmds,final-boost,\
                                                     $(PREFIX),\
                                                     $(finaldir))
uninstall_final-boost    = $(call boost_uninstall_cmds,final-boost,\
                                                       $(PREFIX),\
                                                       $(finaldir))
check_final-boost        = $(call boost_check_cmds,final-boost,\
                                                   $(final_config_flags))

$(call gen_config_rules_with_dep,final-boost,boost,config_final-boost)
$(call gen_clobber_rules,final-boost)
$(call gen_build_rules,final-boost,build_final-boost)
$(call gen_clean_rules,final-boost,clean_final-boost)
$(call gen_install_rules,final-boost,install_final-boost)
$(call gen_uninstall_rules,final-boost,uninstall_final-boost)
$(call gen_check_rules,final-boost,check_final-boost)
$(call gen_dir_rules,final-boost)
