jinja2_dist_url  := https://files.pythonhosted.org/packages/7a/ff/75c28576a1d900e87eb6335b063fab47a8ef3c8b4d88524c4bf78f670cce/Jinja2-3.1.2.tar.gz
jinja2_dist_sum  := 31351a702a408a9e7595a8fc6150fc3f43bb6bf7e319770cbc0db9df9437e852
jinja2_dist_name := $(notdir $(jinja2_dist_url))

define fetch_jinja2_dist
$(call _download,$(jinja2_dist_url),\
                 $(FETCHDIR)/$(jinja2_dist_name).tmp)
cat $(FETCHDIR)/$(jinja2_dist_name).tmp | \
	sha256sum --check --status <(echo "$(jinja2_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(jinja2_dist_name).tmp,\
          $(FETCHDIR)/$(jinja2_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(jinja2_dist_name)'
endef

# As fetch_jinja2_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(jinja2_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,jinja2,\
                       jinja2_dist_name,\
                       fetch_jinja2_dist)

define xtract_jinja2
$(call rmrf,$(srcdir)/jinja2)
$(call untar,$(srcdir)/jinja2,\
             $(FETCHDIR)/$(jinja2_dist_name),\
             --strip-components=1)
cd $(srcdir)/jinja2 && \
patch -p1 < $(PATCHDIR)/jinja-3.1.2-000-fix_deprecated_test_teardown.patch
endef
$(call gen_xtract_rules,jinja2,xtract_jinja2)

$(call gen_dir_rules,jinja2)

# $(1): targets base name / module name
define jinja2_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-jinja2,stage-wheel stage-markupsafe)
$(call gen_check_deps,stage-jinja2,stage-jinja2 stage-pytest)

check_stage-jinja2 = $(call jinja2_check_cmds,stage-jinja2)
$(call gen_python_module_rules,stage-jinja2,\
                               jinja2,\
                               $(stagedir),\
                               ,\
                               check_stage-jinja2)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-jinja2,stage-wheel stage-markupsafe)
$(call gen_check_deps,final-jinja2,stage-jinja2 stage-pytest)

check_final-jinja2 = $(call jinja2_check_cmds,final-jinja2)
$(call gen_python_module_rules,final-jinja2,jinja2,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-jinja2)
