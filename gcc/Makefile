gcc_dist_url      := https://ftp.gnu.org/gnu/gcc/gcc-11.3.0/gcc-11.3.0.tar.xz
gcc_sig_url       := $(gcc_dist_url).sig
gcc_dist          := $(FETCHDIR)/$(notdir $(gcc_dist_url))

binutils_dist_url := https://ftp.gnu.org/gnu/binutils/binutils-2.36.tar.lz
binutils_sig_url  := $(binutils_dist_url).sig
binutils_dist     := $(FETCHDIR)/$(notdir $(binutils_dist_url))

gmp_dist_url      := https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz
gmp_sig_url       := $(gmp_dist_url).sig
gmp_dist          := $(FETCHDIR)/$(notdir $(gmp_dist_url))

mpfr_dist_url     := https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.xz
mpfr_sig_url      := $(mpfr_dist_url).sig
mpfr_dist         := $(FETCHDIR)/$(notdir $(mpfr_dist_url))

mpc_dist_url      := https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz
mpc_sig_url       := $(mpc_dist_url).sig
mpc_dist          := $(FETCHDIR)/$(notdir $(mpc_dist_url))

isl_dist_url      := https://libisl.sourceforge.io/isl-0.24.tar.xz
isl_dist          := $(FETCHDIR)/$(notdir $(isl_dist_url))

fetch_dists       := $(gcc_dist) \
                     $(binutils_dist) \
                     $(gmp_dist) \
                     $(mpfr_dist) \
                     $(mpc_dist) \
                     $(isl_dist)

topsrcdir         := $(abspath $(SRCDIR)/..)

include ../autotools.mk

define fetch_cmds
$(call download_verify_detach,$(gcc_dist_url),$(gcc_sig_url),$(gcc_dist))
$(call download_verify_detach,$(binutils_dist_url), \
                              $(binutils_sig_url), \
                              $(binutils_dist))
$(call download_verify_detach,$(gmp_dist_url),$(gmp_sig_url),$(gmp_dist))
$(call download_verify_detach,$(mpfr_dist_url),$(mpfr_sig_url),$(mpfr_dist))
$(call download_verify_detach,$(mpc_dist_url),$(mpc_sig_url),$(mpc_dist))
$(call download,$(isl_dist_url),$(isl_dist))
endef

define xtract_cmds
$(call rmrf,$(topsrcdir)/binutils)
$(call untar,$(topsrcdir)/binutils,$(binutils_dist),--strip-components=1)
$(call rmrf,$(topsrcdir)/gmp)
$(call untar,$(topsrcdir)/gmp,$(gmp_dist),--strip-components=1)
$(call rmrf,$(topsrcdir)/mpfr)
$(call untar,$(topsrcdir)/mpfr,$(mpfr_dist),--strip-components=1)
$(call rmrf,$(topsrcdir)/mpc)
$(call untar,$(topsrcdir)/mpc,$(mpc_dist),--strip-components=1)
$(call rmrf,$(topsrcdir)/isl)
$(call untar,$(topsrcdir)/isl,$(isl_dist),--strip-components=1)
$(call untar,$(SRCDIR),$(gcc_dist),--strip-components=1)
for e in $(topsrcdir)/binutils/*; do \
	bname="$$(basename $$e)"; \
	if [ ! -e "$(SRCDIR)/$$bname" ]; then \
		ln -s "$(topsrcdir)/binutils/$$bname" "$(SRCDIR)/$$bname"; \
	fi; \
done
ln -s $(topsrcdir)/gmp $(SRCDIR)/gmp
ln -s $(topsrcdir)/mpfr $(SRCDIR)/mpfr
ln -s $(topsrcdir)/mpc $(SRCDIR)/mpc
ln -s $(topsrcdir)/isl $(SRCDIR)/isl
endef

#TODO:
# * check zstd lto support is enabled using gcc -v
# * use --with-pkgversion= / --with-bugurl= ?
# * refine target library build flags using CFLAGS_FOR_TARGET,
#   CXXFLAGS_FOR_TARGET and LDFLAGS_FOR_TARGET
#   (see https://gcc.gnu.org/install/build.html)
# * GPU offload support (https://gcc.gnu.org/wiki/Offloading) ?
# * refine stage build flags, i.e.:
#     stage2 and stage3 build flags: BOOT_CFLAGS
#     stage<n> build flags: STAGE<n>_CFLAGS

define config_cmds
cd $(BUILDDIR) && \
$(SRCDIR)/configure --prefix="$(PREFIX)" \
                    --enable-silent-rules \
                    --enable-nls \
                    --without-included-gettext \
                    --enable-clocale=gnu \
                    --with-system-zlib \
                    --disable-multilib \
                    --enable-languages=c,c++,lto \
                    --enable-threads=posix \
                    --enable-tls \
                    --enable-plugin \
                    --enable-link-serialization \
                    --enable-checkings=yes \
                    --without-cuda-driver \
                    --enable-gnu-unique-object \
                    --with-build-config="bootstrap-lto bootstrap-cet" \
                    --enable-default-pie \
                    --enable-default-ssp \
                    --enable-vtable-verify \
                    --with-arch=native \
                    --with-tune=native \
                    --with-fpmath=avx \
                    --enable-decimal-float=yes \
                    --enable-cet \
                    --enable-lto \
                    --enable-bootstrap
endef

define clobber_cmds
$(call rmrf,$(topsrcdir)/gmp)
$(call rmrf,$(topsrcdir)/mpfr)
$(call rmrf,$(topsrcdir)/mpc)
$(call rmrf,$(topsrcdir)/isl)
$(call rmrf,$(topsrcdir)/binutils)
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
