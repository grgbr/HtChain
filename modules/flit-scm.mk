################################################################################
# flit-scm Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

flit-scm_dist_url  := https://files.pythonhosted.org/packages/e2/99/961b062461652435b6ad9042d2ffdd75e327b36936987c2073aa784334d5/flit_scm-1.7.0.tar.gz
flit-scm_dist_sum  := feea98fd46a32a5d55d7f64c93aca68ea959b89a49e0e0b59017d8ce0c5c9d1ddcae95c713533dca0f7d39314450f04ae5233111c2460437fdbae40f500c0901
flit-scm_dist_name := $(notdir $(flit-scm_dist_url))
flit-scm_vers      := $(patsubst flit_scm-%.tar.gz,%,$(flit-scm_dist_name))
flit-scm_brief     := Python_ PEP 518 build backend
flit-scm_home      := https://gitlab.com/WillDaSilva/flit_scm

define flit-scm_desc
A PEP 518 build backend that uses setuptools-scm_ to generate a version file
from your version control system, then flit_core_ to build the package.
endef

define fetch_flit-scm_dist
$(call download_csum,$(flit-scm_dist_url),\
                     $(FETCHDIR)/$(flit-scm_dist_name),\
                     $(flit-scm_dist_sum))
endef
$(call gen_fetch_rules,flit-scm,flit-scm_dist_name,fetch_flit-scm_dist)

define xtract_flit-scm
$(call rmrf,$(srcdir)/flit-scm)
$(call untar,$(srcdir)/flit-scm,\
             $(FETCHDIR)/$(flit-scm_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flit-scm,xtract_flit-scm)

$(call gen_dir_rules,flit-scm)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flit-scm,stage-setuptools-scm)

$(call gen_python_module_rules,stage-flit-scm,flit-scm,$(stagedir))
