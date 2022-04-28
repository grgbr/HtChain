MKDIR := mkdir
CURL  := curl
GPG   := gpg
TAR   := tar
TOUCH := touch
MV    := mv
SYNC  := sync

PACKAGES := curl \
            gpg \
            tar gzip bzip2 xz-utils lzip \
            patch \
            make autoconf automake m4 libtool-bin pkg-config \
            gcc g++ gperf flex bison \
            gettext intltool \
            libncurses-dev \
            libglade2-dev \
            qtbase5-dev \
            grep sed perl m4 gawk \
            coreutils \
            bash \
            texinfo \
            diffutils \
            libzstd-dev \
            dejagnu tcl python3-pytest autogen \
            \
            libuv1-dev librhash-dev libjsoncpp-dev libnghttp2-dev \
            libcurlpp-dev libarchive-dev \
            python3-sphinx python3-sphinxcontrib.qthelp qhelpgenerator-qt5 \
            python3-sphinx-rtd-theme latexmk texlive-latex-recommended \
            texlive-latex-extra \
            \
            qemu-system-x86

# Use --location for sites where URL points to a page that has moved to a
# different location, e.g. github.
define _download
$(CURL) --silent --location '$(strip $(1))' --output '$(strip $(2))'
endef

define gpg_verify_detach
$(SCRIPTDIR)/gpg_verify.sh --homedir "$(FETCHDIR)/.gnupg" \
                           '$(strip $(1))' \
                           '$(strip $(2))'
endef

define mkdir
$(MKDIR) --parents '$(strip $(1))'
endef

define rmrf
$(RM) --recursive '$(strip $(1))'
endef

define rmf
$(RM) '$(strip $(1))'
endef

define untar
$(MKDIR) --parents '$(strip $(1))'
$(TAR) --extract \
       --directory='$(strip $(1))' \
       --file='$(strip $(2))' \
       $(strip $(3))
endef

define touch
$(TOUCH) '$(strip $(1))'
endef

define mv
$(MV) '$(strip $(1))' '$(strip $(2))'
endef

define download
if [ ! -r "$(strip $(2))" ]; then \
	$(call _download,$(1),$(strip $(2)).tmp) && \
	$(call mv,$(strip $(2)).tmp,$(2)) && \
	$(SYNC) --file-system '$(strip $(2))'; \
fi
endef

define download_verify_detach
if [ ! -r "$(strip $(3))" ]; then \
	$(call _download,$(1),$(strip $(3)).tmp) && \
	$(call _download,$(2),$(strip $(3)).sig) && \
	$(call gpg_verify_detach,$(strip $(3)).sig,$(strip $(3)).tmp) && \
	$(call mv,$(strip $(3)).tmp,$(3)) && \
	$(SYNC) --file-system '$(strip $(3))'; \
fi
endef

$(OUTDIR)/pkgs-setup: | $(OUTDIR)
	sudo apt-get --assume-yes update
	sudo apt-get --assume-yes --no-upgrade install $(PACKAGES)
	$(call touch,$(@))

$(OUTDIR)/sigs-setup: $(OUTDIR)/pkgs-setup | $(FETCHDIR)
	$(SCRIPTDIR)/gpg_setup.sh $(FETCHDIR)
	$(call touch,$(@))

$(FETCHDIR) $(BUILDDIR) $(STAMPDIR) $(SRCDIR) $(OUTDIR):
	$(call mkdir,$(@))
