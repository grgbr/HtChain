################################################################################
# setuptools-scm Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

setuptools-scm_dist_url  := https://files.pythonhosted.org/packages/98/12/2c1e579bb968759fc512391473340d0661b1a8c96a59fb7c65b02eec1321/setuptools_scm-7.1.0.tar.gz
setuptools-scm_dist_sum  := bd7260672c213db6b8c5842dbb6ac69e69ce040777865c935033971f65d905bd8e6b54e174190a924e452c302e69d4c1de231cbc8f603176ba013a739840dad3
setuptools-scm_dist_name := $(notdir $(setuptools-scm_dist_url))
setuptools-scm_vers      := $(patsubst setuptools-scm-%.tar.gz,%,$(setuptools-scm_dist_name))
setuptools-scm_brief     := Blessed package to manage your versions by scm tags for Python_
setuptools-scm_home      := https://github.com/pypa/setuptools_scm/

define setuptools-scm_desc
setuptools_scm handles managing your Python_ package versions in scm metadata.
It also handles file finders for the suppertes scm's.
endef

define fetch_setuptools-scm_dist
$(call download_csum,$(setuptools-scm_dist_url),\
                     $(setuptools-scm_dist_name),\
                     $(setuptools-scm_dist_sum))
endef
$(call gen_fetch_rules,setuptools-scm,\
                       setuptools-scm_dist_name,\
                       fetch_setuptools-scm_dist)

define xtract_setuptools-scm
$(call rmrf,$(srcdir)/setuptools-scm)
$(call untar,$(srcdir)/setuptools-scm,\
             $(FETCHDIR)/$(setuptools-scm_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,setuptools-scm,xtract_setuptools-scm)

$(call gen_dir_rules,setuptools-scm)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-setuptools-scm,stage-wheel \
                                     stage-packaging \
                                     stage-tomli \
                                     stage-typing-extensions)

$(call gen_python_module_rules,stage-setuptools-scm,setuptools-scm,$(stagedir))
