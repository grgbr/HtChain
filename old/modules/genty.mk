genty_dist_url  := https://files.pythonhosted.org/packages/c9/bc/eee096fe9ecf1041944f1327cf6a2030fb2c59acd66580b692eb8b540233/genty-1.3.2.tar.gz
genty_dist_sum  := 2e3f5bfe2d3a757c0e2a48ac4716bca42d3b76d9cfc3401ef606635049c35dab
genty_dist_name := $(notdir $(genty_dist_url))

define fetch_genty_dist
$(call _download,$(genty_dist_url),\
                 $(FETCHDIR)/$(genty_dist_name).tmp)
cat $(FETCHDIR)/$(genty_dist_name).tmp | \
	sha256sum --check --status <(echo "$(genty_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(genty_dist_name).tmp,\
          $(FETCHDIR)/$(genty_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(genty_dist_name)'
endef

# As fetch_genty_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(genty_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,genty,\
                       genty_dist_name,\
                       fetch_genty_dist)

define xtract_genty
$(call rmrf,$(srcdir)/genty)
$(call untar,$(srcdir)/genty,\
             $(FETCHDIR)/$(genty_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,genty,xtract_genty)

$(call gen_dir_rules,genty)

# $(1): targets base name / module name
#
# Genty tests are based upon unittest (not pytest)
define genty_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stage_python) -m unittest discover
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-genty,stage-six)
$(call gen_check_deps,stage-genty,stage-mock stage-pytest)

check_stage-genty = $(call genty_check_cmds,stage-genty)
$(call gen_python_module_rules,stage-genty,\
                               genty,\
                               $(stagedir),\
                               ,\
                               check_stage-genty)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-genty,stage-six)
$(call gen_check_deps,final-genty,stage-mock stage-pytest)

check_final-genty = $(call genty_check_cmds,final-genty)
$(call gen_python_module_rules,final-genty,genty,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-genty)
