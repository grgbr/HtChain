################################################################################
# Read the Docs Sphinx extensions Python modules
################################################################################

# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

readthedocs-sphinx-ext_dist_url  := https://files.pythonhosted.org/packages/f3/55/9e440437dcf29ad69963247050872acb981e0ab728c3cc2405b66d124593/readthedocs-sphinx-ext-2.2.0.tar.gz
readthedocs-sphinx-ext_dist_sum  := 8f7009a0716751de2fe2fed726aa08bb382d15ef6c4fb66e6c29537f985a92ab7cc137f81a4f6200e794cb7f495ebf561356194f57c694509b67e7686bef52c5
readthedocs-sphinx-ext_dist_name := $(notdir $(readthedocs-sphinx-ext_dist_url))
readthedocs-sphinx-ext_vers      := $(patsubst readthedocs-sphinx-ext-%.tar.gz,%,$(readthedocs-sphinx-ext_dist_name))
readthedocs-sphinx-ext_brief     := Sphinx_ extension for Read the Docs overrides
readthedocs-sphinx-ext_home      := http://github.com/readthedocs/readthedocs-sphinx-ext

define readthedocs-sphinx-ext_desc
This module adds extensions that make Sphinx_ easier to use. Some of them
require `Read the Docs <https://readthedocs.org/>`_ features, others are just
code that we ship and enable during builds on Read the Docs.

We currently ship:

* an extension for building docs like
  `Read the Docs <https://readthedocs.org/>`_;
* template-meta, allowing users to specify template overrides in per-page
  context.
endef

define fetch_readthedocs-sphinx-ext_dist
$(call download_csum,$(readthedocs-sphinx-ext_dist_url),\
                     $(readthedocs-sphinx-ext_dist_name),\
                     $(readthedocs-sphinx-ext_dist_sum))
endef
$(call gen_fetch_rules,readthedocs-sphinx-ext,\
                       readthedocs-sphinx-ext_dist_name,\
                       fetch_readthedocs-sphinx-ext_dist)

define xtract_readthedocs-sphinx-ext
$(call rmrf,$(srcdir)/readthedocs-sphinx-ext)
$(call untar,$(srcdir)/readthedocs-sphinx-ext,\
             $(FETCHDIR)/$(readthedocs-sphinx-ext_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,readthedocs-sphinx-ext,xtract_readthedocs-sphinx-ext)

$(call gen_dir_rules,readthedocs-sphinx-ext)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-readthedocs-sphinx-ext,\
                stage-requests stage-jinja2 stage-packaging)

$(call gen_python_module_rules,stage-readthedocs-sphinx-ext,\
                               readthedocs-sphinx-ext,$(stagedir))
