include ../autotools.mk

pkg_url := https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
sig_url := https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz.sig
tarball := $(FETCHDIR)/$(notdir $(pkg_url))

define fetch_cmds
$(call download,$(pkg_url),$(tarball))
$(call download,$(sig_url),$(tarball).sig)
$(call gpg_verify_detach,$(tarball).sig,$(tarball))
endef

define xtract_cmds
$(call untar,$(tarball),--strip-components=1)
endef

define config_cmds
cd $(BUILDDIR) && \
./configure --prefix="$(PREFIX)" \
            --enable-silent-rules \
            --enable-c++ \
            --disable-assert \
            --enable-changeword \
            CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
            LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)"
endef

define build_cmds
$(MAKE) -C $(BUILDDIR) all
endef

define clean_cmds
$(MAKE) -C $(BUILDDIR) clean
endef

define install_cmds
$(MAKE) -C $(BUILDDIR) install-strip DESTDIR="$(DESTDIR)"
endef

define uninstall_cmds
$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(DESTDIR)"
endef
