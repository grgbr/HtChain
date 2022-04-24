pkg_url     := https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.tar.gz
sig_url     := $(pkg_url).asc
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include ../autotools.mk

define fetch_cmds
$(call download_verify_detach,$(pkg_url),$(sig_url),$(tarball))
endef

define xtract_cmds
$(call untar,$(BUILDDIR),$(tarball),--strip-components=1)
cd $(BUILDDIR) && patch -p1 < $(CURDIR)/glib_gdate_Werror_format_nonliteral.patch
endef

define config_cmds
cd $(BUILDDIR) && \
./configure --prefix="$(PREFIX)" \
            --enable-silent-rules \
            --with-internal-glib \
            CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
            LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)"
endef

define build_cmds
+$(MAKE) -C $(BUILDDIR) all
endef

define clean_cmds
+$(MAKE) -C $(BUILDDIR) clean
endef

define install_cmds
+$(MAKE) -C $(BUILDDIR) install-strip DESTDIR="$(DESTDIR)"
endef

define uninstall_cmds
+$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(DESTDIR)"
endef
