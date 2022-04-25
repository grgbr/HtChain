pkg_url     := https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
sig_url     := $(pkg_url).sig
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include ../autotools.mk

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
	--enable-silent-rules \
	--enable-ltdl-install \
	CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
	LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)"
endef

define build_cmds
+$(MAKE) -C $(BUILDDIR) all
endef

define install_cmds
+$(MAKE) -C $(BUILDDIR) install-strip DESTDIR="$(DESTDIR)"
endef

define uninstall_cmds
+$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(DESTDIR)"
endef
