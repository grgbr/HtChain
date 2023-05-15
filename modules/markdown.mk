################################################################################
# markdown Python modules
################################################################################

markdown_dist_url  := https://files.pythonhosted.org/packages/85/7e/133e943e97a943d2f1d8bae0c5060f8ac50e6691754eb9dbe036b047a9bb/Markdown-3.4.1.tar.gz
markdown_dist_sum  := 73b0006ac8aaf281a2dbc2c14534853dbb7ab26a620f3961975279feb83334b6868fa4bbcd30767189201a0c84e502dacd16783de3808393699ace0cbaab30a8
markdown_dist_name := $(subst M,m,$(notdir $(markdown_dist_url)))
markdown_vers      := $(patsubst markdown-%.tar.gz,%,$(markdown_dist_name))
markdown_brief     := Python_ text-to-HTML conversion
markdown_home      := https://github.com/Python-Markdown/markdown

define markdown_desc
Markdown is a text-to-HTML conversion tool for web writers. Markdown allows you
to write using an easy-to-read, easy-to-write plain text format, then convert it
to structurally valid XHTML (or HTML).

This is a Python_ implementation of John Gruber\'s Markdown. The current version
implements all Markdown syntax features and fully passes Markdown Test Suite
1.0. It also supports footnotes and attributes.
endef

define fetch_markdown_dist
$(call download_csum,$(markdown_dist_url),\
                     $(markdown_dist_name),\
                     $(markdown_dist_sum))
endef
$(call gen_fetch_rules,markdown,markdown_dist_name,fetch_markdown_dist)

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
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) -m unittest discover --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-markdown = $(call markdown_check_cmds,stage-markdown)

$(call gen_deps,stage-markdown,stage-pyyaml)
$(call gen_python_module_rules,stage-markdown,\
                               markdown,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

final-markdown_shebang_fixups := bin/markdown_py

define install_final-markdown
$(call python_module_install_cmds,final-markdown,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-markdown_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

check_final-markdown = $(call markdown_check_cmds,final-markdown)

$(call gen_deps,final-markdown,stage-pyyaml)
$(call gen_python_module_rules,final-markdown,\
                               markdown,\
                               $(PREFIX),\
                               $(finaldir))
