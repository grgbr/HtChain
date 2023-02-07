# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

wcag-contrast-ratio_dist_url  := https://files.pythonhosted.org/packages/1f/ec/faf3e7ee407a00081372632cdd9858302c8a9bb071e3767f8dac2ac3f9e2/wcag-contrast-ratio-0.9.tar.gz
wcag-contrast-ratio_dist_sum  := 69192b8e5c0a7d0dc5ff1187eeb3e398141633a4bde51c69c87f58fe87ed361c
wcag-contrast-ratio_dist_name := $(notdir $(wcag-contrast-ratio_dist_url))

define fetch_wcag-contrast-ratio_dist
$(call _download,$(wcag-contrast-ratio_dist_url),\
                 $(FETCHDIR)/$(wcag-contrast-ratio_dist_name).tmp)
cat $(FETCHDIR)/$(wcag-contrast-ratio_dist_name).tmp | \
	sha256sum --check --status <(echo "$(wcag-contrast-ratio_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(wcag-contrast-ratio_dist_name).tmp,\
          $(FETCHDIR)/$(wcag-contrast-ratio_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(wcag-contrast-ratio_dist_name)'
endef

# As fetch_wcag-contrast-ratio_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(wcag-contrast-ratio_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,wcag-contrast-ratio,\
                       wcag-contrast-ratio_dist_name,\
                       fetch_wcag-contrast-ratio_dist)

define xtract_wcag-contrast-ratio
$(call rmrf,$(srcdir)/wcag-contrast-ratio)
$(call untar,$(srcdir)/wcag-contrast-ratio,\
             $(FETCHDIR)/$(wcag-contrast-ratio_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,wcag-contrast-ratio,xtract_wcag-contrast-ratio)

$(call gen_dir_rules,wcag-contrast-ratio)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-wcag-contrast-ratio,stage-wheel)

$(call gen_python_module_rules,stage-wcag-contrast-ratio,\
                               wcag-contrast-ratio,$(stagedir))
