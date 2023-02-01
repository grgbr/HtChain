# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pycparser_dist_url  := https://files.pythonhosted.org/packages/5e/0b/95d387f5f4433cb0f53ff7ad859bd2c6051051cebbb564f139a999ab46de/pycparser-2.21.tar.gz
pycparser_dist_sum  := e644fdec12f7872f86c58ff790da456218b10f863970249516d60a5eaca77206
pycparser_dist_name := $(notdir $(pycparser_dist_url))

define fetch_pycparser_dist
$(call _download,$(pycparser_dist_url),$(FETCHDIR)/$(pycparser_dist_name).tmp)
cat $(FETCHDIR)/$(pycparser_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pycparser_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pycparser_dist_name).tmp,\
          $(FETCHDIR)/$(pycparser_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pycparser_dist_name)'
endef

# As fetch_pycparser_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pycparser_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pycparser,pycparser_dist_name,fetch_pycparser_dist)

define xtract_pycparser
$(call rmrf,$(srcdir)/pycparser)
$(call untar,$(srcdir)/pycparser,\
             $(FETCHDIR)/$(pycparser_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pycparser,xtract_pycparser)

$(call gen_dir_rules,pycparser)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pycparser,stage-python)

$(call gen_python_module_rules,stage-pycparser,pycparser,$(stagedir))
