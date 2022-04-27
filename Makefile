OUTDIR   := $(CURDIR)/out
FETCHDIR := $(OUTDIR)/fetch
SRCDIR   := $(OUTDIR)/src
BUILDDIR := $(OUTDIR)/build
STAMPDIR := $(OUTDIR)/stamp
PREFIX   := $(HOME)/devel/root
DESTDIR  :=

# As of gcc 10.2.1 -fvtable-verify cannot be specified together with lto
# See https://gcc.gnu.org/legacy-ml/gcc-patches/2019-09/msg00222.html

MACHINE_CFLAGS  := -march=native
MACHINE_LDFLAGS := $(MACHINE_CFLAGS)
OPTIM_CFLAGS    := -O2 -flto=auto -fuse-linker-plugin
OPTIM_LDFLAGS   := $(OPTIM_CFLAGS)
HARDEN_CFLAGS   := -D_FORTIFY_SOURCE=2 \
                   -DNDEBUG \
                   -fpie \
                   -fstack-protector-strong -fstack-clash-protection \
                   -fcf-protection=full
HARDEN_LDFLAGS  := -pie -Wl,-z,now -Wl,-z,relro -Wl,-z,noexecstack

# TODO: make flex depend on bison
projects := make m4 autoconf automake libtool kconfig-frontends pkg-config \
            gperf bison flex gcc cmake bmake

.NOTPARALLEL:

TOPDIR    := $(CURDIR)
SCRIPTDIR := $(CURDIR)/scripts

include helpers.mk

packages := curl \
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
            texlive-latex-extra

define setup_pkgs_cmd
sudo apt --yes update && sudo apt --yes install $(packages)
endef

.PHONY: setup-pkgs
setup-pkgs: | $(STAMPDIR)
	$(call setup_pkgs_cmd)
	$(call touch,$(STAMPDIR)/pkgs-setup)
$(STAMPDIR)/pkgs-setup: | $(STAMPDIR)
	$(call setup_pkgs_cmd)
	$(call touch,$(@))

define setup_sigs_cmd
scripts/gpg_setup.sh $(FETCHDIR)
endef

.PHONY: setup-sigs
setup-sigs: $(STAMPDIR)/pkgs-setup | $(FETCHDIR)
	$(call setup_sigs_cmd)
	$(call touch,$(STAMPDIR)/sigs-setup)
$(STAMPDIR)/sigs-setup: $(STAMPDIR)/pkgs-setup | $(FETCHDIR)
	$(call setup_sigs_cmd)
	$(call touch,$(@))

.PHONY: setup
setup: setup-pkgs setup-sigs

define make_cmd
	+$(MAKE) -C $(1) \
	        $(2) \
	        TOPDIR="$(TOPDIR)" \
	        SRCDIR="$(SRCDIR)/$(1)" \
	        SCRIPTDIR="$(SCRIPTDIR)" \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(1)" \
	        STAMPDIR="$(STAMPDIR)/$(1)" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)" \
	        MACHINE_CFLAGS="$(MACHINE_CFLAGS)" \
	        MACHINE_LDFLAGS="$(MACHINE_LDFLAGS)" \
	        OPTIM_CFLAGS="$(OPTIM_CFLAGS)" \
	        OPTIM_LDFLAGS="$(OPTIM_LDFLAGS)" \
	        HARDEN_CFLAGS="$(HARDEN_CFLAGS)" \
	        HARDEN_LDFLAGS="$(HARDEN_LDFLAGS)"
endef

.PHONY: fetch
fetch: $(addprefix $(STAMPDIR)/,$(addsuffix /fetched,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /fetched,$(projects))): \
	$(STAMPDIR)/sigs-setup
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/fetched,%,$(@)),fetch)
.PHONY: $(addprefix fetch-,$(projects))
$(addprefix fetch-,$(projects)): $(STAMPDIR)/sigs-setup
	$(call rmf,$(STAMPDIR)/$(subst fetch-,,$(@))/fetched)
	$(call make_cmd,$(subst fetch-,,$(@)),fetch)

.PHONY: xtract
xtract: $(addprefix $(STAMPDIR)/,$(addsuffix /xtracted,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /xtracted,$(projects))): \
	$(STAMPDIR)/sigs-setup
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/xtracted,%,$(@)),xtract)
.PHONY: $(addprefix xtract-,$(projects))
$(addprefix xtract-,$(projects)): $(STAMPDIR)/sigs-setup
	$(call rmf,$(STAMPDIR)/$(subst xtract-,,$(@))/xtracted)
	$(call make_cmd,$(subst xtract-,,$(@)),xtract)

.PHONY: config
config: $(addprefix $(STAMPDIR)/,$(addsuffix /configured,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /configured,$(projects))): \
	$(STAMPDIR)/sigs-setup
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/configured,%,$(@)),config)
.PHONY: $(addprefix config-,$(projects))
$(addprefix config-,$(projects)): $(STAMPDIR)/sigs-setup
	$(call rmf,$(STAMPDIR)/$(subst config-,,$(@))/configured)
	$(call make_cmd,$(subst config-,,$(@)),config)

.PHONY: clobber
clobber: $(addprefix clobber-,$(projects))
$(addprefix clobber-,$(projects)): clobber-%:
	$(call make_cmd,$(subst clobber-,,$(@)),clobber)

.PHONY: build
build: $(addprefix $(STAMPDIR)/,$(addsuffix /built,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /built,$(projects))): \
	$(STAMPDIR)/sigs-setup
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/built,%,$(@)),build)
.PHONY: $(addprefix build-,$(projects))
$(addprefix build-,$(projects)): $(STAMPDIR)/sigs-setup
	$(call rmf,$(STAMPDIR)/$(subst build-,,$(@))/built)
	$(call make_cmd,$(subst build-,,$(@)),build)

.PHONY: clean
clean: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): clean-%:
	$(call make_cmd,$(subst clean-,,$(@)),clean)

.PHONY: install
install: $(addprefix $(STAMPDIR)/,$(addsuffix /installed,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /installed,$(projects))): \
	$(STAMPDIR)/sigs-setup
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/installed,%,$(@)),install)
.PHONY: $(addprefix install-,$(projects))
$(addprefix install-,$(projects)): $(STAMPDIR)/sigs-setup
	$(call rmf,$(STAMPDIR)/$(subst install-,,$(@))/installed)
	$(call make_cmd,$(subst install-,,$(@)),install)

$(projects): %: $(STAMPDIR)/%/installed

.PHONY: uninstall
uninstall: $(addprefix uninstall-,$(projects))
$(addprefix uninstall-,$(projects)): uninstall-%:
	$(call make_cmd,$(subst uninstall-,,$(@)),uninstall)

.PHONY: mproper
mrproper: uninstall
	$(call rmrf,$(OUTDIR))
$(addprefix mrproper-,$(projects)): mrproper-%:
	$(call make_cmd,$(subst mrproper-,,$(@)),mrproper)

.PHONY: all
all: $(projects)
