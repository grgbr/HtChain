################################################################################
# sphinx Python modules
################################################################################

sphinx_dist_url  := https://files.pythonhosted.org/packages/db/0b/a0f60c4abd8a69bd5b0d20edde8a8d8d9d4ca825bbd920d328d248fd0290/Sphinx-6.1.3.tar.gz
sphinx_dist_sum  := 97970f9c25355a5d40dedc7386415b84634f753f1f384ea2bbcee127ffcb637deca088daac615dce21518a32270b70e7e268321c72a4997d64d5eae99edadfbe
sphinx_dist_name := $(subst S,s,$(notdir $(sphinx_dist_url)))
sphinx_vers      := $(patsubst sphinx-%.tar.gz,%,$(sphinx_dist_name))
sphinx_brief     := Documentation generator for Python_ projects
sphinx_home      := https://www.sphinx-doc.org/

define sphinx_desc
Sphinx is a tool for producing documentation for Python_ projects, using
reStructuredText as markup language.

Sphinx features:

* HTML, CHM, LaTeX output,
* cross-referencing source code,
* automatic indices,
* code highlighting, using Pygments_,
* extensibility.

Existing extensions:

  * automatic testing of code snippets,
  * including docstrings from Python_ modules.
endef

define fetch_sphinx_dist
$(call download_csum,$(sphinx_dist_url),\
                     $(FETCHDIR)/$(sphinx_dist_name),\
                     $(sphinx_dist_sum))
endef
$(call gen_fetch_rules,sphinx,sphinx_dist_name,fetch_sphinx_dist)

define xtract_sphinx
$(call rmrf,$(srcdir)/sphinx)
$(call untar,$(srcdir)/sphinx,\
             $(FETCHDIR)/$(sphinx_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinx,xtract_sphinx)

$(call gen_dir_rules,sphinx)

# $(1): targets base name / module name
#
# Disable lualatex tests since not supporting lualatex engine (using xelatex
# instead).
# Have 2 --verbose to export full log error
define sphinx_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    SSL_CERT_DIR="/etc/ssl/certs" \
$(stagedir)/bin/pytest \
	--verbose --verbose \
	--deselect "tests/test_build_latex.py::test_build_latex_doc[lualatex-howto]" \
	--deselect "tests/test_build_latex.py::test_build_latex_doc[lualatex-manual]"
endef

################################################################################
# Staging definitions
################################################################################

check_stage-sphinx = $(call sphinx_check_cmds,stage-sphinx)

$(call gen_deps,stage-sphinx,stage-alabaster \
                             stage-babel \
                             stage-certifi \
                             stage-charset-normalizer \
                             stage-docutils \
                             stage-idna \
                             stage-imagesize \
                             stage-markupsafe \
                             stage-jinja2 \
                             stage-packaging \
                             stage-pygments \
                             stage-pytz \
                             stage-requests \
                             stage-snowballstemmer \
                             stage-sphinxcontrib-applehelp \
                             stage-sphinxcontrib-devhelp \
                             stage-sphinxcontrib-htmlhelp \
                             stage-sphinxcontrib-jsmath \
                             stage-sphinxcontrib-qthelp \
                             stage-sphinxcontrib-serializinghtml \
                             stage-urllib3)
$(call gen_check_deps,stage-sphinx,\
                      stage-pytest \
                      stage-html5lib \
                      stage-hypothesis \
                      stage-cython)
$(call gen_python_module_rules,stage-sphinx,sphinx,$(stagedir))

################################################################################
# Final definitions
################################################################################

final-sphinx_shebang_fixups := bin/sphinx-build \
                               bin/sphinx-apidoc \
                               bin/sphinx-autogen \
                               bin/sphinx-quickstart

define install_final-sphinx
$(call python_module_install_cmds,final-sphinx,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-sphinx_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

check_final-sphinx = $(call sphinx_check_cmds,final-sphinx)

$(call gen_deps,final-sphinx,stage-alabaster \
                             stage-babel \
                             stage-certifi \
                             stage-charset-normalizer \
                             stage-docutils \
                             stage-idna \
                             stage-imagesize \
                             stage-markupsafe \
                             stage-jinja2 \
                             stage-packaging \
                             stage-pygments \
                             stage-pytz \
                             stage-requests \
                             stage-snowballstemmer \
                             stage-sphinxcontrib-applehelp \
                             stage-sphinxcontrib-devhelp \
                             stage-sphinxcontrib-htmlhelp \
                             stage-sphinxcontrib-jsmath \
                             stage-sphinxcontrib-qthelp \
                             stage-sphinxcontrib-serializinghtml \
                             stage-urllib3)
$(call gen_check_deps,final-sphinx,stage-pytest \
                                   stage-html5lib \
                                   stage-hypothesis \
                                   stage-cython)
$(call gen_python_module_rules,final-sphinx,sphinx,$(PREFIX),$(finaldir))
