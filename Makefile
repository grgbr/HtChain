OUTDIR   := $(CURDIR)/out
FETCHDIR := $(OUTDIR)/fetch
PREFIX   := /opt/htchain
DESTDIR  :=
DEBDIST  :=
DEBORIG  := $(shell hostname --short)
DEBMAIL  := $(USER)@$(shell hostname --short)

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

################################################################################
# Do not touch these unless you really known what you are doing...
################################################################################

TOPDIR            := $(CURDIR)
override OUTDIR   := $(strip $(OUTDIR))
override FETCHDIR := $(strip $(FETCHDIR))
override PREFIX   := $(strip $(PREFIX))
override DESTDIR  := $(strip $(DESTDIR))
override DEBDIST  := $(strip $(DEBDIST))
override DEBORIG  := $(strip $(DEBORIG))
override DEBMAIL  := $(strip $(DEBMAIL))

ifeq ($(strip $(JOBS)),)
# Compute number of available CPUs.
# Note: we should use the number of online CPUs...
JOBS := $(shell grep '^processor[[:blank:]]\+:' /proc/cpuinfo | wc -l)
endif

# Debian based distribution codename probing
debdist := $(if $(DEBDIST),$(DEBDIST),$(shell lsb_release -cs))
ifeq ($(realpath $(TOPDIR)/debian/$(debdist).mk),)
$(error Unsupported build distribution '$(debdist)')
endif
include $(TOPDIR)/debian/$(debdist).mk
export DEBSRCDEPS DEBBINDEPS

ifneq ($(realpath /.dockerenv),)
outdir          := $(OUTDIR)/$(debdist)
else
outdir          := $(OUTDIR)/current
endif
# Where sources are extracted
srcdir          := $(outdir)/src
# Where compile / link happens
builddir        := $(outdir)/build
# Install destination base directory
stagedir        := $(outdir)/stage
# Pathname to base directory used to build debian package.
debdir          := $(outdir)/debian
# Base timestamps directory location
stampdir        := $(outdir)/stamp

# TODO: make flex depend on bison
projects := make m4 autoconf automake libtool kconfig-frontends pkg-config \
            gperf bison flex gcc cmake bmake ncurses python ninja meson

.NOTPARALLEL:

include helpers.mk

ifeq ($(DEBDIST),)

MAKEFLAGS += --jobs $(JOBS)

.PHONY: setup
setup: setup-pkgs setup-sigs
.PHONY: setup-pkgs
setup-pkgs:
	$(call setup_pkgs_cmds)
.PHONY: setup-sigs
setup-sigs:
	$(call setup_sigs_cmds)

define make_cmd
	+$(MAKE) --directory="$(1)" \
	         $(2) \
	         TOPDIR="$(TOPDIR)" \
	         OUTDIR="$(OUTDIR)" \
	         FETCHDIR="$(FETCHDIR)" \
	         SRCDIR="$(srcdir)/$(1)" \
	         BUILDDIR="$(builddir)/$(1)" \
	         STAGEDIR="$(stagedir)" \
	         STAMPDIR="$(stampdir)/$(1)" \
	         PREFIX="$(PREFIX)" \
	         MACHINE_CFLAGS="$(MACHINE_CFLAGS)" \
	         MACHINE_LDFLAGS="$(MACHINE_LDFLAGS)" \
	         OPTIM_CFLAGS="$(OPTIM_CFLAGS)" \
	         OPTIM_LDFLAGS="$(OPTIM_LDFLAGS)" \
	         HARDEN_CFLAGS="$(HARDEN_CFLAGS)" \
	         HARDEN_LDFLAGS="$(HARDEN_LDFLAGS)"
endef

.PHONY: all
all: $(projects)

.PHONY: fetch
fetch: $(addprefix $(OUTDIR)/stamp/,$(addsuffix /fetched,$(projects)))
$(addprefix $(OUTDIR)/stamp/,$(addsuffix /fetched,$(projects))):
	$(call make_cmd,$(patsubst $(OUTDIR)/stamp/%/fetched,%,$(@)),fetch)
.PHONY: $(addprefix fetch-,$(projects))
$(addprefix fetch-,$(projects)):
	$(call rmf,$(OUTDIR)/stamp/$(subst fetch-,,$(@))/fetched)
	$(call make_cmd,$(subst fetch-,,$(@)),fetch)

.PHONY: xtract
xtract: $(addprefix $(stampdir)/,$(addsuffix /xtracted,$(projects)))
$(addprefix $(stampdir)/,$(addsuffix /xtracted,$(projects))):
	$(call make_cmd,$(patsubst $(stampdir)/%/xtracted,%,$(@)),xtract)
.PHONY: $(addprefix xtract-,$(projects))
$(addprefix xtract-,$(projects)):
	$(call rmf,$(stampdir)/$(subst xtract-,,$(@))/xtracted)
	$(call make_cmd,$(subst xtract-,,$(@)),xtract)

.PHONY: config
config: $(addprefix $(stampdir)/,$(addsuffix /configured,$(projects)))
$(addprefix $(stampdir)/,$(addsuffix /configured,$(projects))):
	$(call make_cmd,$(patsubst $(stampdir)/%/configured,%,$(@)),config)
.PHONY: $(addprefix config-,$(projects))
$(addprefix config-,$(projects)):
	$(call rmf,$(stampdir)/$(subst config-,,$(@))/configured)
	$(call make_cmd,$(subst config-,,$(@)),config)

.PHONY: clobber
clobber:
	$(call rmrf,$(outdir))
$(addprefix clobber-,$(projects)): clobber-%:
	$(call make_cmd,$(subst clobber-,,$(@)),clobber)

.PHONY: build
build: $(addprefix $(stampdir)/,$(addsuffix /built,$(projects)))
$(addprefix $(stampdir)/,$(addsuffix /built,$(projects))):
	$(call make_cmd,$(patsubst $(stampdir)/%/built,%,$(@)),build)
.PHONY: $(addprefix build-,$(projects))
$(addprefix build-,$(projects)):
	$(call rmf,$(stampdir)/$(subst build-,,$(@))/built)
	$(call make_cmd,$(subst build-,,$(@)),build)

.PHONY: clean
clean: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): clean-%:
	$(call make_cmd,$(subst clean-,,$(@)),clean)

.PHONY: install
install: $(addprefix $(stampdir)/,$(addsuffix /installed,$(projects)))
$(addprefix $(stampdir)/,$(addsuffix /installed,$(projects))):
	$(call make_cmd,$(patsubst $(stampdir)/%/installed,%,$(@)),install)
.PHONY: $(addprefix install-,$(projects))
$(addprefix install-,$(projects)):
	$(call rmf,$(stampdir)/$(subst install-,,$(@))/installed)
	$(call make_cmd,$(subst install-,,$(@)),install)

.PHONY: $(projects)
$(projects): %: $(stampdir)/%/installed

.PHONY: uninstall
uninstall:
	find $(stampdir) -maxdepth 2 -name installed -delete
	$(call rmrf,$(stagedir))
$(addprefix uninstall-,$(projects)): uninstall-%:
	$(call make_cmd,$(subst uninstall-,,$(@)),uninstall)

.PHONY: mproper
mrproper: uninstall
	$(call rmrf,$(OUTDIR))

.PHONY: deploy
deploy: $(addprefix $(stampdir)/,$(addsuffix /installed,$(projects)))
	$(call mirror_cmd,$(stagedir)$(PREFIX),$(DESTDIR)$(PREFIX))
	$(call strip_cmd,$(DESTDIR)$(PREFIX))

version    := $(shell $(scriptdir)/localversion.sh "$(TOPDIR)")
debarch    := $(shell dpkg --print-architecture)
debbindeps := $(subst $(space),$(comma)$(space),$(strip $(DEBBINDEPS)))
debfile    := $(outdir)/htchain_$(version)_$(debarch).deb

.PHONY: debian
debian: $(debfile)
$(debfile): $(addprefix $(stampdir)/,$(addsuffix /installed,$(projects))) \
            $(TOPDIR)/debian/control.in \
            Makefile
	$(call rmrf,$(debdir))
	$(MKDIR) --parents --mode=755 $(debdir)$(PREFIX)
	$(call _mirror_cmd,$(stagedir)$(PREFIX),$(debdir)$(PREFIX))
	$(call strip_cmd,$(debdir)$(PREFIX))
	$(MKDIR) --mode=755 $(debdir)/DEBIAN
	umask=0022 && \
	sed --expression='s/@@DEBVERS@@/$(version)/g' \
	    --expression='s/@@DEBDIST@@/$(debdist)/g' \
	    --expression='s/@@DEBORIG@@/$(DEBORIG)/g' \
	    --expression='s/@@DEBARCH@@/$(debarch)/g' \
	    --expression='s/@@DEBMAIL@@/$(DEBMAIL)/g' \
	    --expression='s/@@DEBBINDEPS@@/$(debbindeps)/g' \
	    $(TOPDIR)/debian/control.in > $(debdir)/DEBIAN/control
	fakeroot dpkg-deb --build "$(debdir)" "$(outdir)"

else  #!ifeq ($(DEBDIST),)

define dock_run_cmd
	docker run \
	       --rm=true \
	       --volume $(TOPDIR):$(TOPDIR):ro \
	       --volume $(OUTDIR):$(OUTDIR):rw \
	       --tty=true \
	       --interactive=true \
	       --env="HTCHAIN_UID=$$(id -u)" \
	       --env="HTCHAIN_USER=$$(id -un)" \
	       --env="HTCHAIN_GID=$$(id -g)" \
	       --env="HTCHAIN_GROUP=$$(id -gn)" \
	       --env="HTCHAIN_HOME=$(HOME)" \
	       --entrypoint="$(TOPDIR)/scripts/dock_start.sh" \
	       "htchain:$(strip $(1))" \
	       make --directory="$(TOPDIR)" \
	            $(2) \
	            JOBS="$(JOBS)" \
	            OUTDIR="$(OUTDIR)" \
	            FETCHDIR="$(FETCHDIR)" \
	            PREFIX="$(PREFIX)" \
	            DESTDIR="$(DESTDIR)" \
	            DEBDIST= \
	            DEBORIG="$(DEBORIG)" \
	            DEBMAIL="$(DEBMAIL)"
endef

.PHONY: all
all: $(projects)

.PHONY: fetch
fetch: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),fetch)
.PHONY: $(addprefix fetch-,$(projects))
$(addprefix fetch-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: xtract
xtract: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),xtract)
.PHONY: $(addprefix xtract-,$(projects))
$(addprefix xtract-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: config
config: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),config)
.PHONY: $(addprefix config-,$(projects))
$(addprefix config-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: clobber
clobber:
	$(call rmrf,$(OUTDIR)/$(DEBDIST))
.PHONY: $(addprefix clobber-,$(projects))
$(addprefix clobber-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: build
build: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),build)
.PHONY: $(addprefix build-,$(projects))
$(addprefix build-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: clean
clean: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),clean)
.PHONY: $(addprefix clean-,$(projects))
$(addprefix clean-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: install
install: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),install)
.PHONY: $(addprefix install-,$(projects))
$(addprefix install-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: uninstall
uninstall: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),uninstall)
.PHONY: $(addprefix uninstall-,$(projects))
$(addprefix uninstall-,$(projects)): $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),$(@))

.PHONY: $(projects)
$(projects): %: install-%

.PHONY: deploy
deploy: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),deploy)

.PHONY: debian
debian: $(OUTDIR)/$(DEBDIST)/stamp/docker-ready
	$(call dock_run_cmd,$(DEBDIST),debian)

$(OUTDIR)/$(DEBDIST)/stamp/docker-ready: $(OUTDIR)/$(DEBDIST)/build/Dockerfile \
                                         | $(OUTDIR)/$(DEBDIST)/stamp
	docker build \
	       --file '$(<)' \
	       --tag 'htchain:$(DEBDIST)' \
	       $(TOPDIR)
	$(call touch,$(@))

$(OUTDIR)/$(DEBDIST)/build/Dockerfile: $(TOPDIR)/Dockerfile.in \
                                       $(TOPDIR)/debian/$(DEBDIST).mk \
	                               | $(OUTDIR)/$(DEBDIST)/build
	sed --expression='s/@@DOCKIMG@@/$(DOCKIMG)/g' \
	    --expression='s/@@DEBSRCDEPS@@/$(DEBSRCDEPS)/g' \
	    $(<) > $(@)

$(OUTDIR)/$(DEBDIST)/build $(OUTDIR)/$(DEBDIST)/stamp:
	$(call mkdir,$(@))

endif #ifeq ($(DEBDIST),)
