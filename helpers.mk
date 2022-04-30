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
            libreadline-dev \
            liblzma-dev \
            libssl-dev \
            libmpdec-dev \
            libbz2-dev \
            libgdbm-dev libgdbm-compat-dev \
            libsqlite3-dev \
            tcl-dev \
            tk-dev \
            \
            python3-full \
            re2c \
            qemu-system-x86

empty :=

define newline
$(empty)
$(empty)
endef

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

define setup_pkgs_cmds
sudo apt-get --assume-yes update
sudo apt-get --assume-yes --no-upgrade install $(PACKAGES)
endef

define setup_sigs_cmds
$(SCRIPTDIR)/gpg_setup.sh $(FETCHDIR)
endef

$(OUTDIR)/pkgs-setup: | $(OUTDIR)
	$(call setup_pkgs_cmds)
	$(call touch,$(@))

$(OUTDIR)/sigs-setup: $(OUTDIR)/pkgs-setup | $(FETCHDIR)
	$(call setup_sigs_cmds)
	$(call touch,$(@))

.PHONY: fetch
fetch: $(STAMPDIR)/fetched
$(STAMPDIR)/fetched: $(fetch_dists) | $(STAMPDIR) $(FETCHDIR)
	$(call fetch_cmds)
	$(call touch,$(@))
$(fetch_dists): $(OUTDIR)/sigs-setup | $(FETCHDIR)
	@:

.PHONY: xtract
xtract: $(STAMPDIR)/xtracted
$(STAMPDIR)/xtracted: $(STAMPDIR)/fetched
	$(call rmrf,$(SRCDIR))
	$(call xtract_cmds)
	$(call touch,$(@))

.PHONY: config
config: $(STAMPDIR)/configured
$(STAMPDIR)/configured: $(STAMPDIR)/xtracted | $(BUILDDIR)
	$(call config_cmds)
	$(call touch,$(@))

.PHONY: clobber
clobber: uninstall
	$(if $(realpath $(STAMPDIR)/configured),$(call clobber_cmds))
	$(call rmrf,$(BUILDDIR))
	$(call rmrf,$(STAMPDIR))
	$(call rmrf,$(SRCDIR))

.PHONY: build
build: $(STAMPDIR)/built
$(STAMPDIR)/built: $(STAMPDIR)/configured
	$(call build_cmds)
	$(call touch,$(@))

.PHONY: clean
clean: uninstall
	$(if $(realpath $(STAMPDIR)/built),$(call clean_cmds))
	$(call rmf,$(STAMPDIR)/built)

.PHONY: install
install: $(STAMPDIR)/installed
$(STAMPDIR)/installed: $(STAMPDIR)/built
	$(call install_cmds)
	$(call touch,$(@))

.PHONY: uninstall
uninstall:
	$(if $(realpath $(STAMPDIR)/installed),$(call uninstall_cmds))
	$(call rmf,$(STAMPDIR)/installed)

$(FETCHDIR) $(BUILDDIR) $(STAMPDIR) $(SRCDIR) $(OUTDIR):
	$(call mkdir,$(@))
