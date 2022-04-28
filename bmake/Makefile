pkg_url     := https://www.crufty.net/ftp/pub/sjg/bmake-20220418.tar.gz
sig_url     := $(pkg_url).asc
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include $(TOPDIR)/helpers.mk

define fetch_cmds
$(call download_verify_detach,$(pkg_url),$(sig_url),$(tarball))
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
endef

define config_cmds
cd $(BUILDDIR) && \
$(SRCDIR)/configure \
	--prefix="$(PREFIX)" \
	CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
	LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)"
endef

define build_cmds
+$(MAKE) -C $(BUILDDIR) all
endef

define install_cmds
+$(MAKE) -C $(BUILDDIR) install DESTDIR="$(DESTDIR)"
endef

#TODO: define me
define uninstall_cmds
endef
