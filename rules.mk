include $(TOPDIR)/helpers.mk

# Remove all makefile variables defined by make command line to prevent from
# confliting with internal project makefiles.
MAKEOVERRIDES :=

$(OUTDIR)/stamp/pkgs-setup: | $(OUTDIR)/stamp
	$(call setup_pkgs_cmds)
	$(call touch,$(@))

$(OUTDIR)/stamp/sigs-setup: | $(OUTDIR)/stamp/pkgs-setup $(FETCHDIR)
	$(call setup_sigs_cmds)
	$(call touch,$(@))

.PHONY: fetch
fetch: $(OUTDIR)/stamp/$(notdir $(STAMPDIR))/fetched
$(OUTDIR)/stamp/$(notdir $(STAMPDIR))/fetched: $(fetch_dists) \
                                               | $(OUTDIR)/stamp/$(notdir $(STAMPDIR))
	$(call fetch_cmds)
	$(call touch,$(@))
$(fetch_dists): $(OUTDIR)/stamp/sigs-setup
	@:

.PHONY: xtract
xtract: $(STAMPDIR)/xtracted
$(STAMPDIR)/xtracted: $(OUTDIR)/stamp/$(notdir $(STAMPDIR))/fetched | $(STAMPDIR)
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

$(FETCHDIR) $(BUILDDIR) $(STAMPDIR) $(SRCDIR) $(OUTDIR) $(STAGEDIR) \
$(OUTDIR)/stamp/$(notdir $(STAMPDIR)):
	$(call mkdir,$(@))
