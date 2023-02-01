pygments_dist_url  := https://files.pythonhosted.org/packages/da/6a/c427c06913204e24de28de5300d3f0e809933f376e0b7df95194b2bb3f71/Pygments-2.14.0.tar.gz
pygments_dist_sum  := b3ed06a9e8ac9a9aae5a6f5dbe78a8a58655d17b43b93c078f094ddc476ae297
pygments_dist_name := $(notdir $(pygments_dist_url))

define fetch_pygments_dist
$(call _download,$(pygments_dist_url),$(FETCHDIR)/$(pygments_dist_name).tmp)
cat $(FETCHDIR)/$(pygments_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pygments_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pygments_dist_name).tmp,\
          $(FETCHDIR)/$(pygments_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pygments_dist_name)'
endef

# As fetch_pygments_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pygments_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pygments,pygments_dist_name,fetch_pygments_dist)

define xtract_pygments
$(call rmrf,$(srcdir)/pygments)
$(call untar,$(srcdir)/pygments,\
             $(FETCHDIR)/$(pygments_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pygments,xtract_pygments)

$(call gen_dir_rules,pygments)

# $(1): targets base name / module name
define pygments_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pygments,stage-wheel)
$(call gen_check_deps,stage-pygments,stage-pytest stage-wcag-contrast-ratio)

check_stage-pygments = $(call pygments_check_cmds,stage-pygments)
$(call gen_python_module_rules,stage-pygments,\
                               pygments,\
                               $(stagedir),\
                               ,\
                               check_stage-pygments)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pygments,stage-wheel)
$(call gen_check_deps,final-pygments,stage-pytest stage-wcag-contrast-ratio)

check_final-pygments = $(call pygments_check_cmds,final-pygments)
$(call gen_python_module_rules,final-pygments,\
                               pygments,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pygments)
