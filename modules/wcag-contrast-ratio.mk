################################################################################
# wcag-contrast-ratio Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

wcag-contrast-ratio_dist_url  := https://files.pythonhosted.org/packages/1f/ec/faf3e7ee407a00081372632cdd9858302c8a9bb071e3767f8dac2ac3f9e2/wcag-contrast-ratio-0.9.tar.gz
wcag-contrast-ratio_dist_sum  := 2723b4b317383151724fe8213d0662e401eb562622afcebb5632be7c5b8f643e34859f4ace9e9e95215648ea443c11ddb5d3ab5859dc5d2c93815f5391d5434c
wcag-contrast-ratio_dist_name := $(notdir $(wcag-contrast-ratio_dist_url))
wcag-contrast-ratio_vers      := $(patsubst wcag-contrast-ratio-%.tar.gz,%,$(wcag-contrast-ratio_dist_name))
wcag-contrast-ratio_brief     := Python_ library computing contrast ratios required by WCAG 2.0
wcag-contrast-ratio_home      := https://github.com/gsnedders/wcag-contrast-ratio

define wcag-contrast-ratio_desc
This package provides a Python_ library that calculates the contrast ratio of
colors based on Web Content Accessibility Guidelines (WCAG) 2 standard,
published by the Web Accessibility Initiative (WAI). The actual WCAG technical
documents are created by the Accessibility Guidelines Working Group (AG WG),
which are part of the WAI.

This library also provides some checking if contrast meets the required level.
endef

define fetch_wcag-contrast-ratio_dist
$(call download_csum,$(wcag-contrast-ratio_dist_url),\
                     $(wcag-contrast-ratio_dist_name),\
                     $(wcag-contrast-ratio_dist_sum))
endef
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
