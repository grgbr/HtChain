idna_dist_url  := https://files.pythonhosted.org/packages/8b/e1/43beb3d38dba6cb420cefa297822eac205a277ab43e5ba5d5c46faf96438/idna-3.4.tar.gz
idna_dist_sum  := 814f528e8dead7d329833b91c5faa87d60bf71824cd12a7530b5526063d02cb4
idna_dist_name := $(notdir $(idna_dist_url))

define fetch_idna_dist
$(call _download,$(idna_dist_url),$(FETCHDIR)/$(idna_dist_name).tmp)
cat $(FETCHDIR)/$(idna_dist_name).tmp | \
	sha256sum --check --status <(echo "$(idna_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(idna_dist_name).tmp,\
          $(FETCHDIR)/$(idna_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(idna_dist_name)'
endef

# As fetch_idna_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(idna_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,idna,idna_dist_name,fetch_idna_dist)

define xtract_idna
$(call rmrf,$(srcdir)/idna)
$(call untar,$(srcdir)/idna,\
             $(FETCHDIR)/$(idna_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,idna,xtract_idna)

$(call gen_dir_rules,idna)

# $(1): targets base name / module name
define idna_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-idna,stage-flit_core)
$(call gen_check_deps,stage-idna,stage-pytest)

check_stage-idna = $(call idna_check_cmds,stage-idna)
$(call gen_python_module_rules,stage-idna,\
                               idna,\
                               $(stagedir),\
                               ,\
                               check_stage-idna)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-idna,stage-flit_core)
$(call gen_check_deps,final-idna,stage-pytest)

check_final-idna = $(call idna_check_cmds,final-idna)
$(call gen_python_module_rules,final-idna,\
                               idna,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-idna)
