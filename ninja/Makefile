pkg_url     := https://github.com/ninja-build/ninja/archive/refs/tags/v1.10.2.tar.gz
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include $(TOPDIR)/helpers.mk

define fetch_cmds
$(call download,$(pkg_url),$(tarball))
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
endef

define build_cmds
cd $(BUILDDIR) && \
env CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
    CXXFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
    LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)" \
python3 $(SRCDIR)/configure.py \
	$(if $(V),--verbose) \
	--bootstrap \
	--with-python="$(PREFIX)/bin/python3"
cd $(BUILDDIR) && ./ninja $(if $(V),--verbose) all
endef

define clean_cmds
cd $(BUILDDIR) && ./ninja $(if $(V),--verbose) clean
endef

define install_cmds
install --mode=755 --directory $(DESTDIR)$(PREFIX)/bin
install --mode=755 $(BUILDDIR)/ninja $(DESTDIR)$(PREFIX)/bin/ninja
endef

define uninstall_cmds
+$(call rmf, $(DESTDIR)$(PREFIX)/bin/ninja)
endef
