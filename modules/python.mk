# TODO:
# * fix failing tests: test_asyncio test_asyncio test_socket
python_dist_url   := https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tar.xz
python_sig_url    := $(python_dist_url).sig
python_dist_name  := $(notdir $(python_dist_url))

python_vers       := $(shell echo '$(python_dist_name)' | \
                             sed --silent 's/Python-\([0-9.]\+\)\.tar\..*/\1/p')
_python_vers_toks := $(subst .,$(space),$(python_vers))
python_vers_maj   := $(word 1,$(_python_vers_toks))
python_vers_min   := $(word 2,$(_python_vers_toks))

define fetch_python_dist
$(call download_verify_detach,$(python_dist_url), \
                              $(python_sig_url), \
                              $(FETCHDIR)/$(python_dist_name))
endef
$(call gen_fetch_rules,python,python_dist_name,fetch_python_dist)

define xtract_python
$(call rmrf,$(srcdir)/python)
$(call untar,$(srcdir)/python,\
             $(FETCHDIR)/$(python_dist_name),\
             --strip-components=1)
cd $(srcdir)/python && \
	patch -p1 < $(PATCHDIR)/python-3.10.4-000-ensurepip_force_modules_install.patch
endef
$(call gen_xtract_rules,python,xtract_python)

$(call gen_dir_rules,python)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define python_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/python/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define python_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         all \
         $(verbose)
endef

# $(1): targets base name / module name
define python_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         clean \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define python_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(3)),DESTDIR='$(strip $(3))') \
         $(verbose)
$(call slink,python$(python_vers_maj),$(strip $(3))$(strip $(2))/bin/python)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define python_uninstall_cmds
$(call rmf,$(strip $(3))$(strip $(2))/bin/python)
$(call rmf,$(strip $(3))$(strip $(2))/bin/python$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/pydoc$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/2to3*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/pip$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/bin/idle$(python_vers_maj)*)
$(call rmrf,$(strip $(3))$(strip $(2))/include/python$(python_vers_maj)*)
$(call rmrf,$(strip $(3))$(strip $(2))/lib/python$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/libpython$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/pkgconfig/python-$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/lib/pkgconfig/python$(python_vers_maj)*)
$(call rmf,$(strip $(3))$(strip $(2))/share/man/man1/python$(python_vers_maj)*)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
define python_check_cmds
$(MAKE) -j1 --directory $(builddir)/$(strip $(1)) test
endef

python_common_config_args := --enable-shared \
                             --enable-optimizations \
                             --with-computed-gotos \
                             --with-lto \
                             --enable-ipv6 \
                             --enable-loadable-sqlite-extensions \
                             --with-system-expat \
                             --with-system-ffi \
                             --with-system-libmpdec \
                             --with-readline \
                             --with-openssl='$(stagedir)' \
                             --with-ensurepip=install

################################################################################
# Staging definitions
################################################################################

# Remove -flto from build flags since preventing python configure script to
# properly detect float word ordering. We pass the configure script the
# '--with-lto' option instead.
# Build does not support building in PIE mode.
python_stage_config_args := $(python_common_config_args) \
                            $(call stage_config_flags,$(lto_flags))

$(call gen_deps,stage-python,stage-readline \
                             stage-util-linux \
                             stage-ncurses \
                             stage-gdbm \
                             stage-openssl \
                             stage-pkg-config \
                             stage-libffi \
                             stage-expat \
                             stage-libmpdec \
                             stage-sqlite \
                             stage-bzip2 \
                             stage-xz-utils)

config_stage-python    = $(call python_config_cmds,stage-python,\
                                                   $(stagedir),\
                                                   $(python_stage_config_args))
build_stage-python     = $(call python_build_cmds,stage-python)
clean_stage-python     = $(call python_clean_cmds,stage-python)
install_stage-python   = $(call python_install_cmds,stage-python,$(stagedir))
uninstall_stage-python = $(call python_uninstall_cmds,stage-python,$(stagedir))
check_stage-python     = $(call python_check_cmds,stage-python)

$(call gen_config_rules_with_dep,stage-python,python,config_stage-python)
$(call gen_clobber_rules,stage-python)
$(call gen_build_rules,stage-python,build_stage-python)
$(call gen_clean_rules,stage-python,clean_stage-python)
$(call gen_install_rules,stage-python,install_stage-python)
$(call gen_uninstall_rules,stage-python,uninstall_stage-python)
$(call gen_check_rules,stage-python,check_stage-python)
$(call gen_dir_rules,stage-python)

################################################################################
# Final definitions
################################################################################

python_final_config_args := $(python_common_config_args) \
                            $(call final_config_flags,$(lto_flags)) \
                            LD_LIBRARY_PATH="$(stage_lib_path)"

$(call gen_deps,final-python,stage-readline \
                             stage-util-linux \
                             stage-ncurses \
                             stage-gdbm \
                             stage-openssl \
                             stage-pkg-config \
                             stage-libffi \
                             stage-expat \
                             stage-libmpdec \
                             stage-sqlite \
                             stage-bzip2 \
                             stage-xz-utils \
                             stage-tcl)

config_final-python    = $(call python_config_cmds,final-python,\
                                                   $(PREFIX),\
                                                   $(python_final_config_args))
build_final-python     = $(call python_build_cmds,final-python)
clean_final-python     = $(call python_clean_cmds,final-python)
install_final-python   = $(call python_install_cmds,final-python,\
                                                    $(PREFIX),\
                                                    $(finaldir))
uninstall_final-python = $(call python_uninstall_cmds,final-python,\
                                                      $(PREFIX),\
                                                      $(finaldir))
check_final-python     = $(call python_check_cmds,final-python)

$(call gen_config_rules_with_dep,final-python,python,config_final-python)
$(call gen_clobber_rules,final-python)
$(call gen_build_rules,final-python,build_final-python)
$(call gen_clean_rules,final-python,clean_final-python)
$(call gen_install_rules,final-python,install_final-python)
$(call gen_uninstall_rules,final-python,uninstall_final-python)
$(call gen_check_rules,final-python,check_final-python)
$(call gen_dir_rules,final-python)
