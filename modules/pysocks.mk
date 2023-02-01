# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pysocks_dist_url  := https://files.pythonhosted.org/packages/bd/11/293dd436aea955d45fc4e8a35b6ae7270f5b8e00b53cf6c024c83b657a11/PySocks-1.7.1.tar.gz
pysocks_dist_sum  := 3f8804571ebe159c380ac6de37643bb4685970655d3bba243530d6558b799aa0
pysocks_dist_name := $(notdir $(pysocks_dist_url))

define fetch_pysocks_dist
$(call _download,$(pysocks_dist_url),$(FETCHDIR)/$(pysocks_dist_name).tmp)
cat $(FETCHDIR)/$(pysocks_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pysocks_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pysocks_dist_name).tmp,\
          $(FETCHDIR)/$(pysocks_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pysocks_dist_name)'
endef

# As fetch_pysocks_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pysocks_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pysocks,pysocks_dist_name,fetch_pysocks_dist)

define xtract_pysocks
$(call rmrf,$(srcdir)/pysocks)
$(call untar,$(srcdir)/pysocks,\
             $(FETCHDIR)/$(pysocks_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pysocks,xtract_pysocks)

$(call gen_dir_rules,pysocks)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pysocks,stage-python)

$(call gen_python_module_rules,stage-pysocks,pysocks,$(stagedir))
