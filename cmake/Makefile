pkg_url     := https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1.tar.gz
hash_url    := https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-SHA-256.txt
sig_url     := https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-SHA-256.txt.asc
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include $(TOPDIR)/rules.mk

define fetch_cmds
$(call download,$(pkg_url),$(tarball).down)
$(call download,$(hash_url),$(FETCHDIR)/$(notdir $(hash_url)))
$(call download,$(sig_url),$(FETCHDIR)/$(notdir $(sig_url)))
sed --silent \
    's#$(notdir $(pkg_url))#$(tarball).down#p' \
    '$(FETCHDIR)/$(notdir $(hash_url))' | \
sha256sum --check --status
$(call gpg_verify_detach,$(FETCHDIR)/$(notdir $(sig_url)), \
                         $(FETCHDIR)/$(notdir $(hash_url)))
$(call mv,$(tarball).down,$(tarball))
$(SYNC) --file-system '$(tarball)'
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
cd $(SRCDIR) && patch -p1 < $(CURDIR)/fix_sphinx_pdf_path.patch
cd $(SRCDIR) && patch -p1 < $(CURDIR)/fix_sphinx_share_paths.patch
endef

define config_cmds
+cd $(BUILDDIR) && \
$(SRCDIR)/bootstrap \
	--parallel=0 \
	--prefix="$(PREFIX)" \
	--datadir="/share/cmake" \
	--docdir="/share/doc/cmake" \
	--mandir="/share/man" \
	--system-curl \
	--system-expat \
	--system-jsoncpp \
	--system-zlib \
	--system-bzip2 \
	--system-liblzma \
	--system-nghttp2 \
	--system-zstd \
	--system-libarchive \
	--system-librhash \
	--system-libuv \
	--bootstrap-system-libuv \
	--bootstrap-system-jsoncpp \
	--bootstrap-system-librhash \
	--qt-gui \
	--sphinx-info \
	--sphinx-man \
	--sphinx-html \
	--sphinx-qthelp \
	--sphinx-latexpdf \
	CFLAGS="-I/usr/include/jsoncpp $(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
	CXXFLAGS="-I/usr/include/jsoncpp $(MACHINE_CFLAGS) $(OPTIM_CFLAGS) $(HARDEN_CFLAGS)" \
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
