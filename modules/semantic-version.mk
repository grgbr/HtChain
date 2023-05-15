################################################################################
# semantic-version Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

semantic-version_dist_url  := https://files.pythonhosted.org/packages/7d/31/f2289ce78b9b473d582568c234e104d2a342fd658cc288a7553d83bb8595/semantic_version-2.10.0.tar.gz
semantic-version_dist_sum  := 869a3901d4fc12acb285c94175011ed03dc00b35ab687c67dda458cffab5666cea21bc1b4bf75ef4edeb83b8080452a1c1470248eee54bbd269614a8cab132dc
semantic-version_dist_name := $(notdir $(semantic-version_dist_url))
semantic-version_vers      := $(patsubst semantic-version-%.tar.gz,%,$(semantic-version_dist_name))
semantic-version_brief     := Python_ implementation of the `SemVer <https://semver.org/>`_ scheme
semantic-version_home      := https://github.com/rbarrois/python-semanticversion

define semantic-version_desc
This small library provides a few tools to handle `SemVer
<https://semver.org/>`_ in Python_. It follows strictly the 2.0.0 version of the
`SemVer <https://semver.org/>`_ scheme. semantic_version can also support
versions which wouldn't match the semantic version scheme by converting a
version such as 0.1.2.3.4 into 0.1.2+3.4.
endef

define fetch_semantic-version_dist
$(call download_csum,$(semantic-version_dist_url),\
                     $(semantic-version_dist_name),\
                     $(semantic-version_dist_sum))
endef
$(call gen_fetch_rules,semantic-version,\
                       semantic-version_dist_name,\
                       fetch_semantic-version_dist)

define xtract_semantic-version
$(call rmrf,$(srcdir)/semantic-version)
$(call untar,$(srcdir)/semantic-version,\
             $(FETCHDIR)/$(semantic-version_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,semantic-version,xtract_semantic-version)

$(call gen_dir_rules,semantic-version)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-semantic-version,stage-wheel)

$(call gen_python_module_rules,stage-semantic-version,\
                               semantic-version,\
                               $(stagedir))
