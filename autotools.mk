include ../helpers.mk

.PHONY: fetch
fetch: $(STAMPDIR)/fetched
$(STAMPDIR)/fetched: $(fetch_dists) | $(STAMPDIR) $(FETCHDIR)
	$(call fetch_cmds)
	$(call touch,$(@))
$(fetch_dists): | $(FETCHDIR)
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
	$(call rmf,$(addprefix $(STAMPDIR)/,built))
	$(call rmf,$(addprefix $(STAMPDIR)/,configured))
	$(call rmrf,$(SRCDIR))
	$(call rmf,$(addprefix $(STAMPDIR)/,xtracted))

.PHONY: build
build: $(STAMPDIR)/built
$(STAMPDIR)/built: $(STAMPDIR)/configured
	$(call build_cmds)
	$(call touch,$(@))

.PHONY: clean
clean: uninstall
	$(if $(realpath $(STAMPDIR)/built),$(call clean_cmds))
	$(call rmrf,$(BUILDDIR))
	$(call rmf,$(STAMPDIR)/built)
	$(call rmf,$(STAMPDIR)/configured)

.PHONY: install
install: $(STAMPDIR)/installed
$(STAMPDIR)/installed: $(STAMPDIR)/built
	$(call install_cmds)
	$(call touch,$(@))

.PHONY: uninstall
uninstall:
	$(if $(realpath $(STAMPDIR)/installed),$(call uninstall_cmds))
	$(call rmf,$(STAMPDIR)/installed)
