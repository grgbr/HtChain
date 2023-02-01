# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

click_dist_url  := https://files.pythonhosted.org/packages/59/87/84326af34517fca8c58418d148f2403df25303e02736832403587318e9e8/click-8.1.3.tar.gz
click_dist_sum  := 7682dc8afb30297001674575ea00d1814d808d6a36af415a82bd481d37ba7b8e
click_dist_name := $(notdir $(click_dist_url))

define fetch_click_dist
$(call _download,$(click_dist_url),$(FETCHDIR)/$(click_dist_name).tmp)
cat $(FETCHDIR)/$(click_dist_name).tmp | \
	sha256sum --check --status <(echo "$(click_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(click_dist_name).tmp,\
          $(FETCHDIR)/$(click_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(click_dist_name)'
endef

# As fetch_click_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(click_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,click,click_dist_name,fetch_click_dist)

define xtract_click
$(call rmrf,$(srcdir)/click)
$(call untar,$(srcdir)/click,\
             $(FETCHDIR)/$(click_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,click,xtract_click)

$(call gen_dir_rules,click)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-click,stage-python)

$(call gen_python_module_rules,stage-click,click,$(stagedir))
