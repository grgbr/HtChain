curl_dist_url  := https://curl.se/download/curl-7.84.0.tar.xz
curl_sig_url   := $(curl_dist_url).asc
curl_dist_name := $(notdir $(curl_dist_url))

define fetch_curl_dist
$(call download_verify_detach,$(curl_dist_url), \
                              $(curl_sig_url), \
                              $(FETCHDIR)/$(curl_dist_name))
endef
$(call gen_fetch_rules,curl,curl_dist_name,fetch_curl_dist)

define xtract_curl
$(call rmrf,$(srcdir)/curl)
$(call untar,$(srcdir)/curl,\
             $(FETCHDIR)/$(curl_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,curl,xtract_curl)

$(call gen_dir_rules,curl)

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): configure arguments
define curl_config_cmds
cd $(builddir)/$(strip $(1)) && \
$(srcdir)/curl/configure --prefix='$(strip $(2))' $(3) $(verbose)
endef

# $(1): targets base name / module name
define curl_build_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) all $(verbose)
endef

# $(1): targets base name / module name
define curl_clean_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) clean $(verbose)
endef

# $(1): targets base name / module name
# $(2): optional install destination directory
define curl_install_cmds
+$(MAKE) --directory $(builddir)/$(strip $(1)) \
         install \
         $(if $(strip $(2)),DESTDIR='$(strip $(2))') \
         $(verbose)
endef

# $(1): targets base name / module name
# $(2): build / install prefix
# $(3): optional install destination directory
define curl_uninstall_cmds
-+$(MAKE) --keep-going \
          --directory $(builddir)/$(strip $(1)) \
          uninstall \
          $(if $(3),DESTDIR='$(3)') \
          $(verbose)
$(call cleanup_empty_dirs,$(strip $(3))$(strip $(2)))
endef

# $(1): targets base name / module name
#
# Test suite may be run using the runtests.pl script located into <curl>/tests
# directory (see --help option for supported arguments).
# The script is called by the check make target and passed arguments through the
# TFLAGS makefile variable...
define curl_check_cmds
+env LD_LIBRARY_PATH="$(builddir)/$(strip $(1))/lib/.libs:$(stage_lib_path)" \
$(MAKE) --directory $(builddir)/$(strip $(1)) check TFLAGS="-am"
endef

curl_common_config_args := \
	--enable-silent-rules \
	--disable-debug \
	--enable-optimize \
	--disable-curldebug \
	--enable-symbol-hiding \
	--enable-shared \
	--enable-static \
	--disable-versioned-symbols \
	--enable-progress-meter \
	--with-openssl=$(stagedir) \
	--with-gnu-ld \
	--with-zlib="$(stagedir)" \
	--with-zstd="$(stagedir)" \
	--enable-threaded-resolver \
	--enable-pthreads \
	--disable-ech \
	--disable-smb \
	--without-libidn2 \
	--without-libgsasl \
	--without-libpsl \
	--disable-ldap \
	--enable-http \
	--enable-hsts \
	--enable-ftp \
	--enable-file \
	--enable-rtsp \
	--enable-proxy \
	--enable-dict \
	--enable-telnet \
	--enable-tftp \
	--enable-pop3 \
	--enable-imap \
	--enable-ntlm \
	--enable-smtp \
	--enable-gopher \
	--enable-ipv6 \
	--enable-unix-sockets \
	--enable-cookies \
	--enable-socketpair

################################################################################
# Staging definitions
################################################################################

curl_stage_config_args := $(curl_common_config_args) \
                          --disable-manual \
                          MISSING='true' \
                          $(stage_config_flags)

$(call gen_deps,stage-curl,stage-openssl stage-zlib stage-zstd)

config_stage-curl       = $(call curl_config_cmds,stage-curl,\
                                                  $(stagedir),\
                                                  $(curl_stage_config_args))
build_stage-curl        = $(call curl_build_cmds,stage-curl)
clean_stage-curl        = $(call curl_clean_cmds,stage-curl)
install_stage-curl      = $(call curl_install_cmds,stage-curl)
uninstall_stage-curl    = $(call curl_uninstall_cmds,stage-curl,$(stagedir))
check_stage-curl        = $(call curl_check_cmds,stage-curl)

$(call gen_config_rules_with_dep,stage-curl,curl,config_stage-curl)
$(call gen_clobber_rules,stage-curl)
$(call gen_build_rules,stage-curl,build_stage-curl)
$(call gen_clean_rules,stage-curl,clean_stage-curl)
$(call gen_install_rules,stage-curl,install_stage-curl)
$(call gen_uninstall_rules,stage-curl,uninstall_stage-curl)
$(call gen_check_rules,stage-curl,check_stage-curl)
$(call gen_dir_rules,stage-curl)

################################################################################
# Final definitions
################################################################################

curl_final_config_args := $(curl_common_config_args) \
                          $(final_config_flags)

$(call gen_deps,final-curl,stage-openssl stage-zlib stage-zstd)

config_final-curl       = $(call curl_config_cmds,final-curl,\
                                                  $(PREFIX),\
                                                  $(curl_final_config_args))
build_final-curl        = $(call curl_build_cmds,final-curl)
clean_final-curl        = $(call curl_clean_cmds,final-curl)
install_final-curl      = $(call curl_install_cmds,final-curl,$(finaldir))
uninstall_final-curl    = $(call curl_uninstall_cmds,final-curl,\
                                                     $(PREFIX),\
                                                     $(finaldir))
check_final-curl        = $(call curl_check_cmds,final-curl)

$(call gen_config_rules_with_dep,final-curl,curl,config_final-curl)
$(call gen_clobber_rules,final-curl)
$(call gen_build_rules,final-curl,build_final-curl)
$(call gen_clean_rules,final-curl,clean_final-curl)
$(call gen_install_rules,final-curl,install_final-curl)
$(call gen_uninstall_rules,final-curl,uninstall_final-curl)
$(call gen_check_rules,final-curl,check_final-curl)
$(call gen_dir_rules,final-curl)
