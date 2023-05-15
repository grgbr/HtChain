################################################################################
# Doxygen modules
################################################################################

doxygen_dist_url  := https://www.doxygen.nl/files/doxygen-1.9.6.src.tar.gz
doxygen_dist_sum  := f8b0d19d33fa8a5bb92b38f1c775bd3cde7f024566cf93ed61ab0cafe86643971c04b7f2492364767b3e6ce5b518bad5e0321c82f0a72875ccf936ea7d3595b2
doxygen_dist_name := $(subst .src,,$(notdir $(doxygen_dist_url)))
doxygen_vers      := $(patsubst doxygen-%.tar.gz,%,$(doxygen_dist_name))
doxygen_brief     := Documentation system for programming languages
doxygen_home      := https://www.doxygen.nl/

define doxygen_desc
Doxygen is a documentation system for C, C++, Java, Objective-C, Python, IDL and
to some extent PHP, C#, and D. It can generate an on-line class browser (in
HTML) and/or an off-line reference manual (in LaTeX) from a set of documented
source files. There is also support for generating man pages and for converting
the generated output into Postscript, hyperlinked PDF or compressed HTML. The
documentation is extracted directly from the sources.
endef

define fetch_doxygen_dist
$(call download_csum,$(doxygen_dist_url),\
                     $(doxygen_dist_name),\
                     $(doxygen_dist_sum))
endef
$(call gen_fetch_rules,doxygen,doxygen_dist_name,fetch_doxygen_dist)

define xtract_doxygen
$(call rmrf,$(srcdir)/doxygen)
$(call untar,$(srcdir)/doxygen,\
             $(FETCHDIR)/$(doxygen_dist_name),\
             --strip-components=1)
cd $(srcdir)/doxygen && \
patch -p1 < $(PATCHDIR)/doxygen-1.9.6-000-fix_latex_manual_xpatch.patch
cd $(srcdir)/doxygen && \
patch -p1 < $(PATCHDIR)/doxygen-1.9.6-001-fix_doxyparse_link_flags.patch
$(call rmf,$(srcdir)/doxygen/src/._formula.h \
           $(srcdir)/doxygen/src/._htmlgen.h \
           $(srcdir)/doxygen/templates/html/._resize.js)
endef
$(call gen_xtract_rules,doxygen,xtract_doxygen)

$(call gen_dir_rules,doxygen)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define doxygen_config_cmds
+cd $(builddir)/$(strip $(1)) && \
 env PATH="$(stagedir)/bin:$(PATH)" \
 $(stagedir)/bin/cmake -G "Unix Makefiles" $(srcdir)/doxygen \
                       -DCMAKE_INSTALL_PREFIX="$(strip $(2))" \
                       $(3) \
                       $(verbose)
endef

# $(1): targets base name / module name
define doxygen_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(if $(V),VERBOSE=1) $(verbose)
endef

# $(1): targets base name / module name
define doxygen_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean \
         clean \
         $(if $(V),VERBOSE=1) $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define doxygen_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(if $(V),VERBOSE=1) $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define doxygen_uninstall_cmds
if [ -f $(builddir)/$(strip $(1))/install_manifest.txt ]; then \
	sed -n \
	    's;^\(.\+\)$$;$(strip $(3))\1;p' \
	    $(builddir)/$(strip $(1))/install_manifest.txt | \
	xargs $(RM); \
fi
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define doxygen_check_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         test \
         PATH="$(stagedir)/bin:$(PATH)" \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         VERBOSE=1
endef

doxygen_common_config_args := -DCMAKE_BUILD_TYPE=Release \
                              -DFLEX_EXECUTABLE='$(stage_flex)' \
                              -DBISON_EXECUTABLE='$(stage_bison)' \
                              -DCMAKE_C_COMPILER='$(stage_cc)' \
                              -DCMAKE_CXX_COMPILER='$(stage_cxx)' \
                              -Dbuild_wizard=OFF \
                              -Dbuild_app=OFF \
                              -Duse_sqlite3=OFF \
                              -Duse_libclang=OFF \
                              -Dbuild_search=OFF \
                              -Dbuild_parse=ON \
                              -Dbuild_xmlparser=ON

################################################################################
# Staging definitions
################################################################################

doxygen_stage_config_args := $(doxygen_common_config_args) \
                             -DCMAKE_C_FLAGS='$(stage_cflags)' \
                             -DCMAKE_CXX_FLAGS='$(stage_cxxflags)' \
                             -DDOXYGEN_EXTRA_LINK_OPTIONS='$(stage_ldflags)'

$(call gen_deps,stage-doxygen,stage-cmake stage-flex stage-bison stage-python)
$(call gen_check_deps,stage-doxygen,stage-libxml2)

config_stage-doxygen    = $(call doxygen_config_cmds,\
                                 stage-doxygen,\
                                 $(stagedir),\
                                 $(doxygen_stage_config_args))
build_stage-doxygen     = $(call doxygen_build_cmds,stage-doxygen)
clean_stage-doxygen     = $(call doxygen_clean_cmds,stage-doxygen)
install_stage-doxygen   = $(call doxygen_install_cmds,stage-doxygen)
uninstall_stage-doxygen = $(call doxygen_uninstall_cmds,stage-doxygen,\
                                                        $(stagedir))
check_stage-doxygen     = $(call doxygen_check_cmds,stage-doxygen)

$(call gen_config_rules_with_dep,stage-doxygen,doxygen,config_stage-doxygen)
$(call gen_clobber_rules,stage-doxygen)
$(call gen_build_rules,stage-doxygen,build_stage-doxygen)
$(call gen_clean_rules,stage-doxygen,clean_stage-doxygen)
$(call gen_install_rules,stage-doxygen,install_stage-doxygen)
$(call gen_uninstall_rules,stage-doxygen,uninstall_stage-doxygen)
$(call gen_check_rules,stage-doxygen,check_stage-doxygen)
$(call gen_dir_rules,stage-doxygen)

################################################################################
# Final definitions
################################################################################

doxygen_final_config_args := $(doxygen_common_config_args) \
                             -Dbuild_doc=ON \
                             -DDOC_INSTALL_DIR='share/doc/doxygen' \
                             -DCMAKE_C_FLAGS='$(final_cflags)' \
                             -DCMAKE_CXX_FLAGS='$(final_cxxflags)' \
                             -DDOXYGEN_EXTRA_LINK_OPTIONS='$(final_ldflags)'

$(call gen_deps,final-doxygen,stage-cmake stage-flex stage-bison stage-python)
$(call gen_check_deps,final-doxygen,stage-libxml2)

config_final-doxygen    = $(call doxygen_config_cmds,\
                                 final-doxygen,\
                                 $(PREFIX),\
                                 $(doxygen_final_config_args))
build_final-doxygen     = $(call doxygen_build_cmds,final-doxygen)
clean_final-doxygen     = $(call doxygen_clean_cmds,final-doxygen)

define install_final-doxygen
+$(MAKE) --directory $(builddir)/final-doxygen \
         docs \
         PATH="$(stagedir)/bin:$(PATH)" \
         LD_LIBRARY_PATH="$(stage_lib_path)" \
         $(if $(V),VERBOSE=1) $(verbose)
$(call doxygen_install_cmds,final-doxygen,$(finaldir))
endef

uninstall_final-doxygen = $(call doxygen_uninstall_cmds,final-doxygen,\
                                                        $(PREFIX),\
                                                        $(finaldir))
check_final-doxygen     = $(call doxygen_check_cmds,final-doxygen)

$(call gen_config_rules_with_dep,final-doxygen,doxygen,config_final-doxygen)
$(call gen_clobber_rules,final-doxygen)
$(call gen_build_rules,final-doxygen,build_final-doxygen)
$(call gen_clean_rules,final-doxygen,clean_final-doxygen)
$(call gen_install_rules,final-doxygen,install_final-doxygen)
$(call gen_uninstall_rules,final-doxygen,uninstall_final-doxygen)
$(call gen_check_rules,final-doxygen,check_final-doxygen)
$(call gen_dir_rules,final-doxygen)
