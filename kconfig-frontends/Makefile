include ../helpers.mk

MACHINE_CFLAGS  := -march=native -mhard-float -flto
MACHINE_LDFLAGS := $(MACHINE_CFLAGS)

OPTIM_CFLAGS    := -O2 -flto
OPTIM_LDFLAGS   := $(OPTIM_CFLAGS)

HARDEN_CFLAGS   := -D_FORTIFY_SOURCE=2 \
                   -fpie \
                   -fstack-protector-strong -fstack-clash-protection
HARDEN_LDFLAGS  := -pie -Wl,-z,now -Wl,-z,relro -Wl,-z,noexecstack

pkg_url         := https://salsa.debian.org/philou/kconfig-frontends/-/archive/debian/4.11.0.1+dfsg-6/kconfig-frontends-debian-4.11.0.1+dfsg-6.tar.bz2
tarball         := $(FETCHDIR)/$(notdir $(pkg_url))
config_args     := --prefix="$(PREFIX)" \
                   --enable-frontends="kconfig,conf,gconf,mconf,nconf,qconf" \
                   --enable-silent-rules \
                   CFLAGS="$(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
                   LDFLAGS="$(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)"

.PHONY: install
install: $(STAMPDIR)/built
	$(MAKE) -C $(BUILDDIR) install-strip
	$(call touch,$(STAMPDIR)/installed)

$(STAMPDIR)/installed: $(STAMPDIR)/built
	$(MAKE) -C $(BUILDDIR) install-strip DESTDIR="$(DESTDIR)"
	$(call touch,$(@))

.PHONY: uninstall
uninstall:
	if [ -f "$(STAMPDIR)/installed" ]; then \
		$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(DESTDIR)"; \
	fi
	$(call rmf,$(STAMPDIR)/installed)

.PHONY: build
build: $(STAMPDIR)/configured
	$(MAKE) -C $(BUILDDIR)
	$(call touch,$(STAMPDIR)/built)

$(STAMPDIR)/built: $(STAMPDIR)/configured
	$(MAKE) -C $(BUILDDIR)
	$(call touch,$(@))

.PHONY: clean
clean: uninstall
	if [ -f "$(STAMPDIR)/built" ]; then \
		$(MAKE) -C $(BUILDDIR) clean; \
	fi
	$(call rmf,$(STAMPDIR)/built)

.PHONY: config
config: $(STAMPDIR)/xtracted
	cd $(BUILDDIR) && autoreconf -ivf
	cd $(BUILDDIR) && ./configure $(config_args)
	$(call touch,$(STAMPDIR)/configured)

$(STAMPDIR)/configured: $(STAMPDIR)/xtracted
	cd $(BUILDDIR) && autoreconf -ivf
	cd $(BUILDDIR) && ./configure $(config_args)
	$(call touch,$(@))

.PHONY: clobber
clobber: clean
	if [ -f "$(STAMPDIR)/configured" ]; then \
		$(MAKE) -C $(BUILDDIR) distclean; \
	fi
	$(call rmf,$(STAMPDIR)/configured)

.PHONY: xtract
xtract: $(tarball) | $(STAMPDIR)
	$(call rmrf,$(BUILDDIR))
	$(call untar,$(<),--strip-components=1)
	cd $(BUILDDIR) && \
	for p in $$(grep -v gtk debian/patches/series); do \
		patch -p1 < debian/patches/$$p; \
	done
	$(call touch,$(STAMPDIR)/xtracted)

$(STAMPDIR)/xtracted: $(tarball) | $(STAMPDIR)
	$(call untar,$(<),--strip-components=1)
	cd $(BUILDDIR) && \
	for p in $$(grep -v gtk debian/patches/series); do \
		patch -p1 < debian/patches/$$p; \
	done
	$(call touch,$(@))

.PHONY: fetch
fetch: $(tarball)
$(tarball): | $(FETCHDIR)
	$(call download,$(pkg_url),$(@))

.PHONY: mrproper
mrproper: uninstall
	$(call rmrf,$(BUILDDIR))
	$(call rmrf,$(STAMPDIR))
