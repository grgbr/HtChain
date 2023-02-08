################################################################################
# packaging Python modules
################################################################################

packaging_dist_url  := https://files.pythonhosted.org/packages/47/d5/aca8ff6f49aa5565df1c826e7bf5e85a6df852ee063600c1efa5b932968c/packaging-23.0.tar.gz
packaging_dist_sum  := d8e2af37bf2acb665337983d14de2777d5dd6bda485699b9230d6fd4c21b01525407aa823966b60ac87ac231533b90261e87b371d747b679b6b6cc274ff635d8
packaging_dist_name := $(notdir $(packaging_dist_url))
packaging_vers      := $(patsubst packaging-%.tar.gz,%,$(packaging_dist_name))
packaging_brief     := Core utilities for Python_ packages
packaging_home      := https://pypi.python.org/pypi/packaging

define packaging_desc
These core utilities currently consist of:

* version Handling (PEP 440) ;
* dependency Specification (PEP 440).
endef

define fetch_packaging_dist
$(call download_csum,$(packaging_dist_url),\
                     $(FETCHDIR)/$(packaging_dist_name),\
                     $(packaging_dist_sum))
endef
$(call gen_fetch_rules,packaging,packaging_dist_name,fetch_packaging_dist)

define xtract_packaging
$(call rmrf,$(srcdir)/packaging)
$(call untar,$(srcdir)/packaging,\
             $(FETCHDIR)/$(packaging_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,packaging,xtract_packaging)

$(call gen_dir_rules,packaging)

# $(1): targets base name / module name
define packaging_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-packaging,stage-flit_core)
$(call gen_check_deps,stage-packaging,stage-pytest stage-pretend)

check_stage-packaging = $(call packaging_check_cmds,stage-packaging)
$(call gen_python_module_rules,stage-packaging,\
                               packaging,\
                               $(stagedir),\
                               ,\
                               check_stage-packaging)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-packaging,stage-flit_core)
$(call gen_check_deps,final-packaging,stage-pytest stage-pretend)

check_final-packaging = $(call packaging_check_cmds,final-packaging)
$(call gen_python_module_rules,final-packaging,packaging,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-packaging)
