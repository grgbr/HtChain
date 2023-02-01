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

################################################################################
################################################################################
################################################################################

#define deps_rule
#$(target_stampdir)/$(1)/configured: \
#	$(foreach m,$(2),$(target_stampdir)/$(m)/installed)
#endef
#
## $(1): module name
## $(2): list of modules $(1) depends on
#define gen_deps
#$(eval $(call deps_rule,$(1),$(2)))
#endef
#
#define xtract_rules
#.PHONY: xtract-$(1)
#xtract-$(1): $(target_stampdir)/$(1)/xtracted
#$(target_stampdir)/$(1)/xtracted: | $(target_stampdir)/$(1) \
#                                    $(target_srcdir)/$(1)
#	$$(call log,$(1),extracting)
#	$$($(2))
#	@touch $$(@)
#endef
#
## $(1): module name
## $(2): xtract recipe variable name
#define gen_xtract_rules
#$(eval $(call xtract_rules,$(1),$(2)))
#endef
#
#define config_rules
#.PHONY: config-$(1)
#config-$(1): $(target_stampdir)/$(1)/configured
#$(target_stampdir)/$(1)/configured: $(target_stampdir)/$(1)/xtracted \
#                                    | $(target_builddir)/$(1)
#	$$(call log,$(1),configuring)
#	$$($(2))
#	@touch $$(@)
#endef
#
## $(1): module name
## $(2): config recipe variable name
#define gen_config_rules
#$(eval $(call config_rules,$(1),$(2)))
#endef
#
#define clobber_rules
#.PHONY: clobber-$(1)
#clobber-$(1): uninstall-$(1)
#	$$(call log,$(1),clobbering)
#	$$($(2))
#	$(RM) -r $(target_builddir)/$(1)
#	$(RM) -r $(target_srcdir)/$(1)
#	$(RM) -r $(target_stampdir)/$(1)
#endef
#
## $(1): module name
## $(2): clobber recipe variable name
#define gen_clobber_rules
#$(eval $(call clobber_rules,$(1),$(2)))
#endef
#
#define build_rules
#.PHONY: build-$(1)
#build-$(1): $(target_stampdir)/$(1)/built
#$(target_stampdir)/$(1)/built: $(target_stampdir)/$(1)/configured
#	$$(call log,$(1),building)
#	$$($(2))
#	@touch $$(@)
#endef
#
## $(1): module name
## $(2): build recipe variable name
#define gen_build_rules
#$(eval $(call build_rules,$(1),$(2)))
#endef
#
#define clean_rules
#.PHONY: clean-$(1)
#clean-$(1): uninstall-$(1)
#	$$(call log,$(1),cleaning)
#	$$($(2))
#	$(RM) "$(target_stampdir)/$(1)/built"
#endef
#
## $(1): module name
## $(2): clean recipe variable name
#define gen_clean_rules
#$(eval $(call clean_rules,$(1),$(2)))
#endef
#
#define install_rules
#.PHONY: $(1) install-$(1)
#$(1) install-$(1): $(target_stampdir)/$(1)/installed
#$(target_stampdir)/$(1)/installed: $(target_stampdir)/$(1)/built \
#                                   | $(target_stagedir)
#	$$(call log,$(1),installing)
#	$$($(2))
#	@touch $$(@)
#endef
#
## $(1): module name
## $(2): install recipe variable name
#define gen_install_rules
#$(eval $(call install_rules,$(1),$(2)))
#endef
#
#define uninstall_rules
#.PHONY: uninstall-$(1)
#uninstall-$(1):
#	$$(call log,$(1),uninstalling)
#	$$($(2))
#	$(RM) "$(target_stampdir)/$(1)/installed"
#endef
#
## $(1): module name
## $(2): uninstall recipe variable name
#define gen_uninstall_rules
#$(eval $(call uninstall_rules,$(1),$(2)))
#endef
#
## $(1): module name
#define module_rules
#$(call xtract_rules,$(1),xtract_$(1))
#
#$(call config_rules,$(1),config_$(1))
#$(call clobber_rules,$(1),clobber_$(1))
#
#$(call build_rules,$(1),build_$(1))
#$(call clean_rules,$(1),clean_$(1))
#
#$(call install_rules,$(1),install_$(1))
#$(call uninstall_rules,$(1),uninstall_$(1))
#
#$(target_stampdir)/$(1) \
#$(target_srcdir)/$(1) \
#$(target_builddir)/$(1):
#	@$(call mkdir,$$(@))
#endef
#
## $(1): module name
#define gen_module_rules
#$(eval $(call module_rules,$(1)))
#endef
#
#$(target_stagedir):
#	@$(call mkdir,$(@))
