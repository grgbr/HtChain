pyparsing_dist_url  := https://files.pythonhosted.org/packages/71/22/207523d16464c40a0310d2d4d8926daffa00ac1f5b1576170a32db749636/pyparsing-3.0.9.tar.gz
pyparsing_dist_sum  := 2b020ecf7d21b687f219b71ecad3631f644a47f01403fa1d1036b0c6416d70fb
pyparsing_dist_name := $(notdir $(pyparsing_dist_url))

define fetch_pyparsing_dist
$(call _download,$(pyparsing_dist_url),\
                 $(FETCHDIR)/$(pyparsing_dist_name).tmp)
cat $(FETCHDIR)/$(pyparsing_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pyparsing_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pyparsing_dist_name).tmp,\
          $(FETCHDIR)/$(pyparsing_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pyparsing_dist_name)'
endef

# As fetch_pyparsing_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pyparsing_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pyparsing,\
                       pyparsing_dist_name,\
                       fetch_pyparsing_dist)

define xtract_pyparsing
$(call rmrf,$(srcdir)/pyparsing)
$(call untar,$(srcdir)/pyparsing,\
             $(FETCHDIR)/$(pyparsing_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pyparsing,xtract_pyparsing)

$(call gen_dir_rules,pyparsing)

# $(1): targets base name / module name
define pyparsing_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest
endef
#$(stage_python) setup.py --no-user-cfg test --verbose

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pyparsing,stage-flit_core)
$(call gen_check_deps,stage-pyparsing,\
                      stage-pytest stage-railroad-diagrams stage-jinja2)

check_stage-pyparsing = $(call pyparsing_check_cmds,stage-pyparsing)
$(call gen_python_module_rules,stage-pyparsing,\
                               pyparsing,\
                               $(stagedir),\
                               ,\
                               check_stage-pyparsing)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pyparsing,stage-flit_core)
$(call gen_check_deps,final-pyparsing,\
                      stage-pytest stage-railroad-diagrams stage-jinja2)

check_final-pyparsing = $(call pyparsing_check_cmds,final-pyparsing)
$(call gen_python_module_rules,final-pyparsing,pyparsing,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pyparsing)
