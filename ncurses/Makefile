BUILD_NCURSES_TIC      := env LD_LIBRARY_PATH="$(STAGEDIR)$(PREFIX)/lib" \
                          $(STAGEDIR)$(PREFIX)/bin/tic

pkg_url                := https://ftp.gnu.org/gnu/ncurses/ncurses-6.3.tar.gz
sig_url                := $(pkg_url).sig
tarball                := $(FETCHDIR)/$(notdir $(pkg_url))
rxvt_unicode_tinfo_url := https://raw.githubusercontent.com/exg/rxvt-unicode/rxvt-unicode-9.30/doc/etc/rxvt-unicode.terminfo
rxvt_unicode_tinfo     := $(FETCHDIR)/$(notdir $(rxvt_unicode_tinfo_url))
fetch_dists            := $(tarball) $(rxvt_unicode_tinfo)

include $(TOPDIR)/rules.mk

define fetch_cmds
$(call download_verify_detach,$(pkg_url),$(sig_url),$(tarball))
$(call download,$(rxvt_unicode_tinfo_url),$(rxvt_unicode_tinfo))
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
endef

flags    := $(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)
cppflags := $(filter -D%,$(flags))
cflags   := $(filter-out -D%,$(flags))
ldflags  := $(MACHINE_LDFLAGS) $(OPTIM_LDFLAGS) $(HARDEN_LDFLAGS)

define config_cmds
cd $(BUILDDIR) && \
$(SRCDIR)/configure \
	--prefix="$(PREFIX)" \
	--without-ada \
	--with-pkg-config \
	--with-pkg-config-libdir="$(PREFIX)/lib/pkgconfig" \
	--enable-pc-files \
	--with-shared \
	--with-libtool \
	--with-termlib \
	--with-ticlib \
	--disable-termcap \
	--enable-rpath \
	--disable-root-environ \
	--disable-root-access \
	--enable-symlinks \
	--enable-widec \
	--enable-wattr-macros \
	--enable-sp-funcs \
	--enable-const \
	--enable-ext-colors \
	--enable-ext-putwin \
	--enable-sigwinch \
	--enable-tcap-names \
	CFLAGS="$(cflags)" \
	CXXFLAGS="$(cflags)" \
	CPPFLAGS="$(cppflags)" \
	LDFLAGS="$(ldflags)"
endef

define build_cmds
+$(MAKE) -C $(BUILDDIR) all
endef

define clean_cmds
+$(MAKE) -C $(BUILDDIR) clean
endef

# rxvt-unicode terminfo definitions are not shipped with ncurses distribution.
# Compile and install the one retrieved from the official rxvt-unicode
# repository...
#
# See https://invisible-island.net/ncurses/ncurses-urxvt.html
define install_cmds
+$(MAKE) -C $(BUILDDIR) install DESTDIR="$(STAGEDIR)"
$(BUILD_NCURSES_TIC) -o $(STAGEDIR)$(PREFIX)/share/terminfo \
                        $(rxvt_unicode_tinfo)
endef

define uninstall_cmds
+$(MAKE) -C $(BUILDDIR) uninstall DESTDIR="$(STAGEDIR)"
endef
