xmlschema_dist_url  := https://files.pythonhosted.org/packages/87/82/be78541aeab8d0523d6f967f6fbe892143583978e5f32215f79ac67747e5/xmlschema-2.1.1.tar.gz
xmlschema_dist_sum  := 5ca34ff15dd3276cfb2e3e7b4c8dde4b7d4d27080f333a93b6c3f817e90abddf
xmlschema_dist_name := $(notdir $(xmlschema_dist_url))

define fetch_xmlschema_dist
$(call _download,$(xmlschema_dist_url),$(FETCHDIR)/$(xmlschema_dist_name).tmp)
cat $(FETCHDIR)/$(xmlschema_dist_name).tmp | \
	sha256sum --check --status <(echo "$(xmlschema_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(xmlschema_dist_name).tmp,\
          $(FETCHDIR)/$(xmlschema_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(xmlschema_dist_name)'
endef

# As fetch_xmlschema_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(xmlschema_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,xmlschema,xmlschema_dist_name,fetch_xmlschema_dist)

define xtract_xmlschema
$(call rmrf,$(srcdir)/xmlschema)
$(call untar,$(srcdir)/xmlschema,\
             $(FETCHDIR)/$(xmlschema_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,xmlschema,xtract_xmlschema)

$(call gen_dir_rules,xmlschema)

# $(1): targets base name / module name
define xmlschema_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -v
endef

################################################################################
# Staging definitions
################################################################################
#
#$(call gen_deps,stage-xmlschema,stage-elementpath)
#$(call gen_check_deps,stage-xmlschema,stage-pytest \
#                                      stage-jinja2 \
#                                      stage-coverage \
#                                      stage-lxml)
#
#check_stage-xmlschema = $(call xmlschema_check_cmds,stage-xmlschema)
#$(call gen_python_module_rules,stage-xmlschema,\
#                               xmlschema,\
#                               $(stagedir),\
#                               ,\
#                               check_stage-xmlschema)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-xmlschema,stage-elementpath)
$(call gen_check_deps,final-xmlschema,\
                      stage-pytest \
                      stage-jinja2 \
                      stage-coverage \
                      stage-lxml)

check_final-xmlschema = $(call xmlschema_check_cmds,final-xmlschema)
$(call gen_python_module_rules,final-xmlschema,xmlschema,\
                                                $(PREFIX),\
                                                $(finaldir),\
                                                check_final-xmlschema)
