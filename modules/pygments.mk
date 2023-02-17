################################################################################
# pygments Python modules
################################################################################

pygments_dist_url  := https://files.pythonhosted.org/packages/da/6a/c427c06913204e24de28de5300d3f0e809933f376e0b7df95194b2bb3f71/Pygments-2.14.0.tar.gz
pygments_dist_sum  := 51416a8e2a8d0288cbbf6fd81e6870ffe9d999da255c43d0f870eb5cb4d01660416d136d39fad38b76c4bace3c3aa648fb306519e85e340545a87fc657aaeb15
pygments_dist_name := $(subst P,p,$(notdir $(pygments_dist_url)))
pygments_vers      := $(patsubst pygments-%.tar.gz,%,$(pygments_dist_name))
pygments_brief     := Syntax highlighting package written in Python_
pygments_home      := http://pygments.org/

define pygments_desc
Pygments aims to be a generic syntax highlighter for general use in all kinds of
software such as forum systems, wikis or other applications that need to
prettify source code.

Highlights are:

* a wide range of common languages and markup formats is supported
* special attention is paid to details, increasing quality by a fair amount
* support for new languages and formats are added easily
* a number of output formats, presently HTML, LaTeX and ANSI sequences
* it is usable as a command-line tool and as a library.
endef

define fetch_pygments_dist
$(call download_csum,$(pygments_dist_url),\
                     $(FETCHDIR)/$(pygments_dist_name),\
                     $(pygments_dist_sum))
endef
$(call gen_fetch_rules,pygments,pygments_dist_name,fetch_pygments_dist)

define xtract_pygments
$(call rmrf,$(srcdir)/pygments)
$(call untar,$(srcdir)/pygments,\
             $(FETCHDIR)/$(pygments_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pygments,xtract_pygments)

$(call gen_dir_rules,pygments)

# $(1): targets base name / module name
define pygments_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-pygments = $(call pygments_check_cmds,stage-pygments)

$(call gen_deps,stage-pygments,stage-wheel)
$(call gen_check_deps,stage-pygments,stage-pytest stage-wcag-contrast-ratio)
$(call gen_python_module_rules,stage-pygments,\
                               pygments,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

final-pygments_shebang_fixups := bin/pygmentize

define install_final-pygments
$(call python_module_install_cmds,final-pygments,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-pygments_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

$(call gen_check_deps,final-pygments,stage-pytest stage-wcag-contrast-ratio)

$(call gen_deps,final-pygments,stage-wheel)
check_final-pygments = $(call pygments_check_cmds,final-pygments)
$(call gen_python_module_rules,final-pygments,\
                               pygments,\
                               $(PREFIX),\
                               $(finaldir))
