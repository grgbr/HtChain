lazy_dist_url  := https://files.pythonhosted.org/packages/29/00/ba9688438904f0cd446e1986deb826610385c042776dd939ecb2b360b3bd/lazy-1.5.tar.gz
lazy_dist_sum  := cb3d8612aa895a48afe8f08860573ba8ef5ee4fdbe1b3cd606c5f50a16152186
lazy_dist_name := $(notdir $(lazy_dist_url))

define fetch_lazy_dist
$(call _download,$(lazy_dist_url),$(FETCHDIR)/$(lazy_dist_name).tmp)
cat $(FETCHDIR)/$(lazy_dist_name).tmp | \
	sha256sum --check --status <(echo "$(lazy_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(lazy_dist_name).tmp,\
          $(FETCHDIR)/$(lazy_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(lazy_dist_name)'
endef

# As fetch_lazy_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(lazy_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,lazy,lazy_dist_name,fetch_lazy_dist)

define xtract_lazy
$(call rmrf,$(srcdir)/lazy)
$(call untar,$(srcdir)/lazy,\
             $(FETCHDIR)/$(lazy_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,lazy,xtract_lazy)

$(call gen_dir_rules,lazy)

# $(1): targets base name / module name
define lazy_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-lazy,stage-wheel)
$(call gen_check_deps,stage-lazy,stage-pytest)

check_stage-lazy = $(call lazy_check_cmds,stage-lazy)
$(call gen_python_module_rules,stage-lazy,lazy,\
                                          $(stagedir),\
                                          ,\
                                          check_stage-lazy)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-lazy,stage-wheel)
$(call gen_check_deps,final-lazy,stage-pytest)

check_final-lazy = $(call lazy_check_cmds,final-lazy)
$(call gen_python_module_rules,final-lazy,lazy,\
                                          $(PREFIX),\
                                          $(finaldir),\
                                          check_final-lazy)
