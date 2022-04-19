OUTDIR   := $(CURDIR)/out
FETCHDIR := $(OUTDIR)/fetch
BUILDDIR := $(OUTDIR)/build
STAMPDIR := $(OUTDIR)/stamp
PREFIX   := $(HOME)/devel/root
DESTDIR  :=

projects := kconfig-frontends

include helpers.mk

packages := curl \
            patch \
            autoconf automake libtool-bin pkg-config \
            gcc g++ gperf flex bison \
            gettext intltool \
            libncurses-dev \
            libglade2-dev \
            qtbase5-dev

.PHONY: prepare
prepare:
	apt --yes update
	apt --yes install $(packages)

.PHONY: fetch-all
fetch-all: $(addprefix fetch-,$(projects))
$(addprefix fetch-,$(projects)): fetch-%:
	$(MAKE) -C $(patsubst fetch-%,%,$(@)) \
	        fetch \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst fetch-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst fetch-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: xtract-all
xtract-all: $(addprefix xtract-,$(projects))
$(addprefix xtract-,$(projects)): xtract-%:
	$(MAKE) -C $(patsubst xtract-%,%,$(@)) \
	        xtract \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst xtract-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst xtract-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: config-all
config-all: $(addprefix config-,$(projects))
$(addprefix config-,$(projects)): config-%:
	$(MAKE) -C $(patsubst config-%,%,$(@)) \
	        config \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst config-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst config-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: distclean-all
distclean-all: $(addprefix distclean-,$(projects))
$(addprefix distclean-,$(projects)): distclean-%:
	$(MAKE) -C $(patsubst distclean-%,%,$(@)) \
	        distclean \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst distclean-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst distclean-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: build-all
build-all: $(addprefix build-,$(projects))
$(addprefix build-,$(projects)): build-%:
	$(MAKE) -C $(patsubst build-%,%,$(@)) \
	        build \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst build-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst build-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: clean-all
clean-all: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): clean-%:
	$(MAKE) -C $(patsubst clean-%,%,$(@)) \
	        clean \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst clean-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst clean-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: install-all
install-all: $(addprefix install-,$(projects))
$(addprefix install-,$(projects)): install-%:
	$(MAKE) -C $(patsubst install-%,%,$(@)) \
	        install \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst install-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst install-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: uninstall-all
uninstall-all: $(addprefix uninstall-,$(projects))
$(addprefix uninstall-,$(projects)): uninstall-%:
	$(MAKE) -C $(patsubst uninstall-%,%,$(@)) \
	        uninstall \
	        FETCHDIR="$(FETCHDIR)" \
	        BUILDDIR="$(BUILDDIR)/$(patsubst uninstall-%,%,$(@))" \
	        STAMPDIR="$(STAMPDIR)/$(patsubst uninstall-%,%,$(@))" \
	        PREFIX="$(PREFIX)" \
	        DESTDIR="$(DESTDIR)"

.PHONY: clobber-all
clobber-all:
	$(call rmrf,$(OUTDIR))
