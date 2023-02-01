# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

editables_dist_url  := https://files.pythonhosted.org/packages/01/b0/a2a87db4b6cb8e7d57004b6836faa634e0747e3e39ded126cdbe5a33ba36/editables-0.3.tar.gz
editables_dist_sum  := 167524e377358ed1f1374e61c268f0d7a4bf7dbd046c656f7b410cde16161b1a
editables_dist_name := $(notdir $(editables_dist_url))

define fetch_editables_dist
$(call _download,$(editables_dist_url),$(FETCHDIR)/$(editables_dist_name).tmp)
cat $(FETCHDIR)/$(editables_dist_name).tmp | \
	sha256sum --check --status <(echo "$(editables_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(editables_dist_name).tmp,\
          $(FETCHDIR)/$(editables_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(editables_dist_name)'
endef

# As fetch_editables_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(editables_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,editables,editables_dist_name,fetch_editables_dist)

define xtract_editables
$(call rmrf,$(srcdir)/editables)
$(call untar,$(srcdir)/editables,\
             $(FETCHDIR)/$(editables_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,editables,xtract_editables)

$(call gen_dir_rules,editables)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-editables,stage-wheel)

$(call gen_python_module_rules,stage-editables,editables,$(stagedir))
