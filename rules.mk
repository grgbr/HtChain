include $(TOPDIR)/helpers.mk

# Remove all makefile variables defined by make command line to prevent from
# confliting with internal project makefiles.
MAKEOVERRIDES :=

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
$(STAMPDIR)/installed: $(STAMPDIR)/built | $(STAGEDIR)
	$(call install_cmds)
	$(call touch,$(@))

.PHONY: uninstall
uninstall:
	$(if $(realpath $(STAMPDIR)/installed),$(call uninstall_cmds))
	$(call rmf,$(STAMPDIR)/installed)

$(FETCHDIR) $(BUILDDIR) $(STAMPDIR) $(SRCDIR) $(OUTDIR) $(STAGEDIR):
	$(call mkdir,$(@))
