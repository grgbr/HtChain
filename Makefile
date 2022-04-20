OUTDIR   := $(CURDIR)/out
FETCHDIR := $(OUTDIR)/fetch
BUILDDIR := $(OUTDIR)/build
STAMPDIR := $(OUTDIR)/stamp
PREFIX   := $(HOME)/devel/root
DESTDIR  :=

projects := make m4 kconfig-frontends

include helpers.mk

packages := curl \
            gpg \
            tar gzip bzip2 xz-utils lzip \
            patch \
            autoconf automake m4 libtool-bin pkg-config \
            gcc g++ gperf flex bison \
            gettext intltool \
            libncurses-dev \
            libglade2-dev \
            qtbase5-dev

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

$(FETCHDIR)/.gnupg: $(STAMPDIR)/pkgs-setup | $(FETCHDIR)
	$(call setup_sigs_cmd)

.PHONY: setup
setup: setup-pkgs setup-sigs

define make_cmd
	$(MAKE) -C $(patsubst $(2)-%,%,$(1)) \
	        $(2) \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst $(2)-%,%,$(1))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst $(2)-%,%,$(1))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"
endef

.PHONY: fetch-all
fetch-all: $(addprefix fetch-,$(projects))
$(addprefix fetch-,$(projects)): fetch-%: $(FETCHDIR)/.gnupg
	$(call make_cmd,$(@),fetch)

.PHONY: xtract-all
xtract-all: $(addprefix xtract-,$(projects))
$(addprefix xtract-,$(projects)): xtract-%:
	$(call make_cmd,$(@),xtract)

.PHONY: config-all
config-all: $(addprefix config-,$(projects))
$(addprefix config-,$(projects)): config-%:
	$(call make_cmd,$(@),config)

.PHONY: clobber-all
clobber-all: $(addprefix clobber-,$(projects))
$(addprefix clobber-,$(projects)): clobber-%:
	$(call make_cmd,$(@),clobber)

.PHONY: build-all
build-all: $(addprefix build-,$(projects))
$(addprefix build-,$(projects)): build-%:
	$(call make_cmd,$(@),build)

.PHONY: clean-all
clean-all: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): clean-%:
	$(call make_cmd,$(@),clean)

.PHONY: install-all
install-all: $(addprefix install-,$(projects))
$(addprefix install-,$(projects)): install-%:
	$(call make_cmd,$(@),install)

.PHONY: uninstall-all
uninstall-all: $(addprefix uninstall-,$(projects))
$(addprefix uninstall-,$(projects)): uninstall-%:
	$(call make_cmd,$(@),uninstall)

.PHONY: mproper
mrproper: uninstall-all
	$(call rmrf,$(OUTDIR))
