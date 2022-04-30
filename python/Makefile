pkg_url     := https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tar.xz
sig_url     := $(pkg_url).asc
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

# Remove all makefile variables defined by make command line to prevent from
# confliting with internal python makefiles.
MAKEOVERRIDES :=

include $(TOPDIR)/helpers.mk

define fetch_cmds
$(call download_verify_detach,$(pkg_url),$(sig_url),$(tarball))
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
endef

# Remove -flto from build flags since preventing python configure script to
# properly detect float word ordering.
# We pass the configure script the '--enable-lto' option anyway.
# Build does not support building in PIE mode.
cflags  := $(MACHINE_CFLAGS) \
           $(filter-out -O% -flto% -fuse-linker-plugin,$(OPTIM_CFLAGS)) \
           $(filter-out -fpie,$(HARDEN_CFLAGS))
ldflags := $(MACHINE_LDFLAGS) \
           -O3 $(filter-out -O% -flto% -fuse-linker-plugin,$(OPTIM_LDFLAGS)) \
           $(filter-out -pie,$(HARDEN_LDFLAGS)) \
           -Wl,-rpath,$(PREFIX)/lib

define config_cmds
cd $(BUILDDIR) && \
$(SRCDIR)/configure \
	--prefix="$(PREFIX)" \
	--enable-shared \
	--enable-optimizations \
	--with-computed-gotos \
	--with-lto \
	--enable-ipv6 \
	--enable-loadable-sqlite-extensions \
	--with-system-expat \
	--with-system-ffi \
	--with-system-libmpdec \
	--with-readline \
	CFLAGS="$(cflags)" \
	LDFLAGS="$(ldflags)"
endef

define build_cmds
+$(MAKE) -C $(BUILDDIR) all
endef

define clean_cmds
+$(MAKE) -C $(BUILDDIR) clean
endef

define install_cmds
+$(MAKE) -C $(BUILDDIR) install DESTDIR="$(DESTDIR)"
endef

define uninstall_cmds
+$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(DESTDIR)"
endef
