OUTDIR   := $(CURDIR)/out
FETCHDIR := $(OUTDIR)/fetch
BUILDDIR := $(OUTDIR)/build
STAMPDIR := $(OUTDIR)/stamp
PREFIX   := $(HOME)/devel/root
DESTDIR  :=

MACHINE_CFLAGS  := -march=native -mhard-float
MACHINE_LDFLAGS := $(MACHINE_CFLAGS)
OPTIM_CFLAGS    := -O2 -flto
OPTIM_LDFLAGS   := $(OPTIM_CFLAGS)
HARDEN_CFLAGS   := -D_FORTIFY_SOURCE=2 \
                   -fpie \
                   -fstack-protector-strong -fstack-clash-protection
HARDEN_LDFLAGS  := -pie -Wl,-z,now -Wl,-z,relro -Wl,-z,noexecstack

projects := make m4 autoconf automake kconfig-frontends

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
            qtbase5-dev \
            grep sed perl m4 \
            awk

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
	$(MAKE) -C $(1) \
	        $(2) \
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

.PHONY: fetch-all
fetch: $(addprefix $(STAMPDIR)/,$(addsuffix /fetched,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /fetched,$(projects))): $(FETCHDIR)/.gnupg
$(addprefix fetch-,$(projects)): fetch-%: $(FETCHDIR)/.gnupg
	$(call rmf,$(STAMPDIR)/$(subst fetch-,,$(@))/fetched)
	$(call make_cmd,$(subst fetch-,,$(@)),fetch)

.PHONY: xtract
xtract: $(addprefix $(STAMPDIR)/,$(addsuffix /xtracted,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /xtracted,$(projects))): $(FETCHDIR)/.gnupg
$(addprefix xtract-,$(projects)): xtract-%: $(FETCHDIR)/.gnupg
	$(call rmf,$(STAMPDIR)/$(subst xtract-,,$(@))/xtracted)
	$(call make_cmd,$(subst xtract-,,$(@)),xtract)

.PHONY: config
config: $(addprefix $(STAMPDIR)/,$(addsuffix /configured,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /configured,$(projects))): \
	$(FETCHDIR)/.gnupg
$(addprefix config-,$(projects)): config-%: $(FETCHDIR)/.gnupg
	$(call rmf,$(STAMPDIR)/$(subst config-,,$(@))/configured)
	$(call make_cmd,$(subst config-,,$(@)),config)

.PHONY: clobber
clobber: $(addprefix clobber-,$(projects))
$(addprefix clobber-,$(projects)): clobber-%:
	$(call make_cmd,$(subst clobber-,,$(@)),clobber)

.PHONY: build
build: $(addprefix $(STAMPDIR)/,$(addsuffix /built,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /built,$(projects))): $(FETCHDIR)/.gnupg
$(addprefix build-,$(projects)): build-%: $(FETCHDIR)/.gnupg
	$(call rmf,$(STAMPDIR)/$(subst build-,,$(@))/built)
	$(call make_cmd,$(subst build-,,$(@)),build)

.PHONY: clean
clean: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): clean-%:
	$(call make_cmd,$(subst clean-,,$(@)),clean)

.PHONY: install
install: $(addprefix $(STAMPDIR)/,$(addsuffix /installed,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /installed,$(projects))): \
	$(FETCHDIR)/.gnupg
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/installed,%,$(@)),install)
$(addprefix install-,$(projects)): install-%: $(FETCHDIR)/.gnupg
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
