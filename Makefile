OUTDIR   := $(CURDIR)/out
FETCHDIR := $(OUTDIR)/fetch
SRCDIR   := $(OUTDIR)/src
BUILDDIR := $(OUTDIR)/build
STAMPDIR := $(OUTDIR)/stamp
PREFIX   := $(HOME)/devel/tools/htchain
DESTDIR  :=

# As of gcc 10.2.1 -fvtable-verify cannot be specified together with lto
# See https://gcc.gnu.org/legacy-ml/gcc-patches/2019-09/msg00222.html

MACHINE_CFLAGS  := -march=native
MACHINE_LDFLAGS := $(MACHINE_CFLAGS)
OPTIM_CFLAGS    := -DNDEBUG -O2 -flto=auto -fuse-linker-plugin
OPTIM_LDFLAGS   := $(OPTIM_CFLAGS)
HARDEN_CFLAGS   := -D_FORTIFY_SOURCE=2 \
                   -fpie \
                   -fstack-protector-strong -fstack-clash-protection \
                   -fcf-protection=full
HARDEN_LDFLAGS  := -pie -Wl,-z,now -Wl,-z,relro -Wl,-z,noexecstack

# TODO: make flex depend on bison
projects := make m4 autoconf automake libtool kconfig-frontends pkg-config \
            gperf bison flex gcc cmake bmake ncurses python ninja meson

.NOTPARALLEL:

TOPDIR    := $(CURDIR)
SCRIPTDIR := $(CURDIR)/scripts

include helpers.mk

.PHONY: setup
setup: setup-pkgs setup-sigs
.PHONY: setup-pkgs
setup-pkgs:
	$(call setup_pkgs_cmds)
.PHONY: setup-sigs
setup-sigs:
	$(call setup_sigs_cmds)

define make_cmd
	+$(MAKE) -C $(1) \
	        $(2) \
	        OUTDIR="$(OUTDIR)" \
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
$(addprefix $(STAMPDIR)/,$(addsuffix /fetched,$(projects))):
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/fetched,%,$(@)),fetch)
.PHONY: $(addprefix fetch-,$(projects))
$(addprefix fetch-,$(projects)):
	$(call rmf,$(STAMPDIR)/$(subst fetch-,,$(@))/fetched)
	$(call make_cmd,$(subst fetch-,,$(@)),fetch)

.PHONY: xtract
xtract: $(addprefix $(STAMPDIR)/,$(addsuffix /xtracted,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /xtracted,$(projects))):
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/xtracted,%,$(@)),xtract)
.PHONY: $(addprefix xtract-,$(projects))
$(addprefix xtract-,$(projects)):
	$(call rmf,$(STAMPDIR)/$(subst xtract-,,$(@))/xtracted)
	$(call make_cmd,$(subst xtract-,,$(@)),xtract)

.PHONY: config
config: $(addprefix $(STAMPDIR)/,$(addsuffix /configured,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /configured,$(projects))):
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/configured,%,$(@)),config)
.PHONY: $(addprefix config-,$(projects))
$(addprefix config-,$(projects)):
	$(call rmf,$(STAMPDIR)/$(subst config-,,$(@))/configured)
	$(call make_cmd,$(subst config-,,$(@)),config)

.PHONY: clobber
clobber: $(addprefix clobber-,$(projects))
$(addprefix clobber-,$(projects)): clobber-%:
	$(call make_cmd,$(subst clobber-,,$(@)),clobber)

.PHONY: build
build: $(addprefix $(STAMPDIR)/,$(addsuffix /built,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /built,$(projects))):
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/built,%,$(@)),build)
.PHONY: $(addprefix build-,$(projects))
$(addprefix build-,$(projects)):
	$(call rmf,$(STAMPDIR)/$(subst build-,,$(@))/built)
	$(call make_cmd,$(subst build-,,$(@)),build)

.PHONY: clean
clean: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): clean-%:
	$(call make_cmd,$(subst clean-,,$(@)),clean)

.PHONY: install
install: $(addprefix $(STAMPDIR)/,$(addsuffix /installed,$(projects)))
$(addprefix $(STAMPDIR)/,$(addsuffix /installed,$(projects))):
	$(call make_cmd,$(patsubst $(STAMPDIR)/%/installed,%,$(@)),install)
.PHONY: $(addprefix install-,$(projects))
$(addprefix install-,$(projects)):
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

.PHONY: all
all: $(projects)
