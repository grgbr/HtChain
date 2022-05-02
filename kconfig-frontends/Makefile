pkg_url     := https://salsa.debian.org/philou/kconfig-frontends/-/archive/debian/4.11.0.1+dfsg-6/kconfig-frontends-debian-4.11.0.1+dfsg-6.tar.bz2
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include $(TOPDIR)/rules.mk

define fetch_cmds
$(call download,$(pkg_url),$(tarball))
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
cd $(SRCDIR) && \
for p in $$(grep -v gtk debian/patches/series); do \
	patch -p1 < debian/patches/$$p; \
done
endef

# QT frontend may not support building in PIE mode if platform QT was built with
# -reduce-relocations
define config_cmds
cd $(SRCDIR) && autoreconf --install --force
cd $(BUILDDIR) && \
$(SRCDIR)/configure \
	--prefix="$(PREFIX)" \
	--enable-frontends="kconfig,conf,gconf,mconf,nconf,qconf" \
	--enable-silent-rules \
	CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
	CXXFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(subst -fpie,,$(HARDEN_CFLAGS))" \
	LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)"
endef

define build_cmds
+$(MAKE) -C $(BUILDDIR) all
endef

define clean_cmds
+$(MAKE) -C $(BUILDDIR) clean
endef

define install_cmds
+$(MAKE) -C $(BUILDDIR) install DESTDIR="$(STAGEDIR)"
endef

define uninstall_cmds
+$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(STAGEDIR)"
endef
