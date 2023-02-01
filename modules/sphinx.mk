sphinx_dist_url  := https://files.pythonhosted.org/packages/db/0b/a0f60c4abd8a69bd5b0d20edde8a8d8d9d4ca825bbd920d328d248fd0290/Sphinx-6.1.3.tar.gz
sphinx_dist_sum  := 0dac3b698538ffef41716cf97ba26c1c7788dba73ce6f150c1ff5b4720786dd2
sphinx_dist_name := $(notdir $(sphinx_dist_url))

define fetch_sphinx_dist
$(call _download,$(sphinx_dist_url),$(FETCHDIR)/$(sphinx_dist_name).tmp)
cat $(FETCHDIR)/$(sphinx_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinx_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinx_dist_name).tmp,\
          $(FETCHDIR)/$(sphinx_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinx_dist_name)'
endef
# As fetch_sphinx_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinx_dist_name): SHELL:=/bin/bash
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
define sphinx_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    SSL_CERT_DIR="/etc/ssl/certs" \
$(stagedir)/bin/pytest \
	--verbose \
	--deselect "tests/test_build_latex.py::test_build_latex_doc[lualatex-howto]" \
	--deselect "tests/test_build_latex.py::test_build_latex_doc[lualatex-manual]"
endef

################################################################################
# Staging definitions
################################################################################

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

check_stage-sphinx = $(call sphinx_check_cmds,stage-sphinx)
$(call gen_python_module_rules,stage-sphinx,\
                               sphinx,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinx)

################################################################################
# Final definitions
################################################################################

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

check_final-sphinx = $(call sphinx_check_cmds,final-sphinx)
$(call gen_python_module_rules,final-sphinx,\
                               sphinx,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinx)
