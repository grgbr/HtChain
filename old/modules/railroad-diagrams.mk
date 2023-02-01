railroad-diagrams_dist_url  := https://files.pythonhosted.org/packages/db/7f/e1171866a1e3a6a5663e136f7575c0bba686b6e9a1527e41bdcbaad24aff/railroad-diagrams-2.0.4.tar.gz
railroad-diagrams_dist_sum  := 7413ffa194583bd510efc3e4668f61d5a38beeca186bb7c36eea6d0d6f03fb45
railroad-diagrams_dist_name := $(notdir $(railroad-diagrams_dist_url))

define fetch_railroad-diagrams_dist
$(call _download,$(railroad-diagrams_dist_url),\
                 $(FETCHDIR)/$(railroad-diagrams_dist_name).tmp)
cat $(FETCHDIR)/$(railroad-diagrams_dist_name).tmp | \
	sha256sum --check --status <(echo "$(railroad-diagrams_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(railroad-diagrams_dist_name).tmp,\
          $(FETCHDIR)/$(railroad-diagrams_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(railroad-diagrams_dist_name)'
endef

# As fetch_railroad-diagrams_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(railroad-diagrams_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,railroad-diagrams,\
                       railroad-diagrams_dist_name,\
                       fetch_railroad-diagrams_dist)

define xtract_railroad-diagrams
$(call rmrf,$(srcdir)/railroad-diagrams)
$(call untar,$(srcdir)/railroad-diagrams,\
             $(FETCHDIR)/$(railroad-diagrams_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,railroad-diagrams,xtract_railroad-diagrams)

$(call gen_dir_rules,railroad-diagrams)

# $(1): targets base name / module name
define railroad-diagrams_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest
endef
#$(stage_python) setup.py --no-user-cfg test --verbose

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-railroad-diagrams,stage-python)

$(call gen_python_module_rules,stage-railroad-diagrams,\
                               railroad-diagrams,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-railroad-diagrams,stage-python)

$(call gen_python_module_rules,final-railroad-diagrams,railroad-diagrams,\
                               $(PREFIX),\
                               $(finaldir))
