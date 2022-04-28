pkg_url     := https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz
sig_url     := $(pkg_url).sig
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
cd $(BUILDDIR) && $(SRCDIR)/configure --prefix="$(PREFIX)" --enable-silent-rules
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
