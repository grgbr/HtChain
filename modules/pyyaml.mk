################################################################################
# pyyaml Python modules
################################################################################

pyyaml_dist_url  := https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz
pyyaml_dist_sum  := b402993073282e7f4202823b051d364b91929362edd5b3aebe93b56833956ec9279c1ba82b97f8bc8a2b82d20e1060e4ec9fc90400a6ed902adce3e4f83a6e0e
pyyaml_vers      := $(patsubst PyYAML-%.tar.gz,%,$(notdir $(pyyaml_dist_url)))
pyyaml_dist_name := pyyaml-$(pyyaml_vers).tar.gz
pyyaml_brief     := YAML parser and emitter for Python_
pyyaml_home      := https://pyyaml.org/

define pyyaml_desc
YAML is a data serialization format designed for human readability and
interaction with scripting languages. PyYAML is a YAML parser and emitter for
Python_.

PyYAML features a complete YAML 1.1 parser, Unicode support, pickle support,
capable extension API, and sensible error messages. PyYAML supports standard
YAML tags and provides Python-specific tags that allow to represent an arbitrary
Python_ object.

PyYAML is applicable for a broad range of tasks from complex configuration files
to object serialization and persistence.
endef

define fetch_pyyaml_dist
$(call download_csum,$(pyyaml_dist_url),\
                     $(FETCHDIR)/$(pyyaml_dist_name),\
                     $(pyyaml_dist_sum))
endef
$(call gen_fetch_rules,pyyaml,pyyaml_dist_name,fetch_pyyaml_dist)

define xtract_pyyaml
$(call rmrf,$(srcdir)/pyyaml)
$(call untar,$(srcdir)/pyyaml,\
             $(FETCHDIR)/$(pyyaml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pyyaml,xtract_pyyaml)

$(call gen_dir_rules,pyyaml)

# $(1): targets base name / module name
define pyyaml_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) setup.py --no-user-cfg test
endef

################################################################################
# Staging definitions
################################################################################

check_stage-pyyaml = $(call pyyaml_check_cmds,stage-pyyaml)

$(call gen_deps,stage-pyyaml,stage-wheel stage-cython stage-libyaml)
$(call gen_python_module_rules,stage-pyyaml,pyyaml,$(stagedir))

################################################################################
# Final definitions
################################################################################

final-pyyaml_ext_lib_names := _yaml

final-pyyaml_rpath_fixups = \
	$(addprefix $(python_site_path_comp)/yaml/,\
	            $(addsuffix $(python_ext_lib_suffix),\
	                        $(final-pyyaml_ext_lib_names)))

define install_final-pyyaml
$(call python_module_install_cmds,final-pyyaml,$(PREFIX),$(finaldir))
$(call fixup_rpath,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-pyyaml_rpath_fixups)),\
       $(final_lib_path))
endef

check_final-pyyaml = $(call pyyaml_check_cmds,final-pyyaml)

$(call gen_deps,final-pyyaml,stage-wheel stage-cython stage-libyaml)
$(call gen_python_module_rules,final-pyyaml,pyyaml,$(PREFIX),$(finaldir))
