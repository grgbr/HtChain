markdown_dist_url  := https://files.pythonhosted.org/packages/85/7e/133e943e97a943d2f1d8bae0c5060f8ac50e6691754eb9dbe036b047a9bb/Markdown-3.4.1.tar.gz
markdown_dist_sum  := 3b809086bb6efad416156e00a0da66fe47618a5d6918dd688f53f40c8e4cfeff
markdown_dist_name := $(notdir $(markdown_dist_url))

define fetch_markdown_dist
$(call _download,$(markdown_dist_url),\
                 $(FETCHDIR)/$(markdown_dist_name).tmp)
cat $(FETCHDIR)/$(markdown_dist_name).tmp | \
	sha256sum --check --status <(echo "$(markdown_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(markdown_dist_name).tmp,\
          $(FETCHDIR)/$(markdown_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(markdown_dist_name)'
endef

# As fetch_markdown_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(markdown_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,markdown,\
                       markdown_dist_name,\
                       fetch_markdown_dist)

define xtract_markdown
$(call rmrf,$(srcdir)/markdown)
$(call untar,$(srcdir)/markdown,\
             $(FETCHDIR)/$(markdown_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,markdown,xtract_markdown)

$(call gen_dir_rules,markdown)

# $(1): targets base name / module name
define markdown_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) -m unittest discover --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-markdown,stage-pyyaml)

check_stage-markdown = $(call markdown_check_cmds,stage-markdown)
$(call gen_python_module_rules,stage-markdown,\
                               markdown,\
                               $(stagedir),\
                               ,\
                               check_stage-markdown)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-markdown,stage-pyyaml)

check_final-markdown = $(call markdown_check_cmds,final-markdown)
$(call gen_python_module_rules,final-markdown,\
                               markdown,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-markdown)
