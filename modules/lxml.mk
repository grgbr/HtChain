lxml_dist_url  := https://files.pythonhosted.org/packages/70/bb/7a2c7b4f8f434aa1ee801704bf08f1e53d7b5feba3d5313ab17003477808/lxml-4.9.1.tar.gz
lxml_dist_sum  := fe749b052bb7233fe5d072fcb549221a8cb1a16725c47c37e42b0b9cb3ff2c3f
lxml_dist_name := $(notdir $(lxml_dist_url))

define fetch_lxml_dist
$(call _download,$(lxml_dist_url),$(FETCHDIR)/$(lxml_dist_name).tmp)
cat $(FETCHDIR)/$(lxml_dist_name).tmp | \
	sha256sum --check --status <(echo "$(lxml_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(lxml_dist_name).tmp,\
          $(FETCHDIR)/$(lxml_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(lxml_dist_name)'
endef

# As fetch_lxml_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(lxml_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,lxml,lxml_dist_name,fetch_lxml_dist)

define xtract_lxml
$(call rmrf,$(srcdir)/lxml)
$(call untar,$(srcdir)/lxml,\
             $(FETCHDIR)/$(lxml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,lxml,xtract_lxml)

$(call gen_dir_rules,lxml)

# $(1): targets base name / module name
define lxml_check_cmds
+$(MAKE) -C $(builddir)/$(strip $(1)) \
	inplace3 \
	PATH="$(stagedir)/bin:$(PATH)"
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) test.py -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-lxml,stage-wheel stage-libxml2 stage-libxslt)
$(call gen_check_deps,stage-lxml,stage-pytest)

check_stage-lxml = $(call lxml_check_cmds,stage-lxml)
$(call gen_python_module_rules,stage-lxml,lxml,$(stagedir),,check_stage-lxml)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-lxml,stage-wheel stage-libxml2 stage-libxslt)
$(call gen_check_deps,final-lxml,stage-pytest)

check_final-lxml = $(call lxml_check_cmds,final-lxml)
$(call gen_python_module_rules,final-lxml,\
                               lxml,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-lxml)
