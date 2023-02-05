################################################################################
# flit_core Python modules
################################################################################

flit_core_dist_url  := https://files.pythonhosted.org/packages/10/e5/be08751d07b30889af130cec20955c987a74380a10058e6e8856e4010afc/flit_core-3.8.0.tar.gz
flit_core_dist_sum  := 914804e3f2040762381afe039272d9d6fdbcd3f3cf8b9eea854f2f1d95edcb01718fd6685476bc1cdc251dfc46ef80b40f087df881d8b963dcc3f3332fd32a46
flit_core_dist_name := $(notdir $(flit_core_dist_url))
flit_core_vers      := $(patsubst flit_core-%.tar.gz,%,$(flit_core_dist_name))
flit_core_brief     := Simple way to put Python_ packages and modules on `PyPI <https://pypi.org/>`_ (PEP 517)
flit_core_home      := https://flit.pypa.io/en/latest/

define flit_core_desc
Flit is a easy way to put Python_ packages and modules on `PyPI
<https://pypi.org/>`_. It tries to require less thought about packaging and help
you avoid common mistakes.

Flit supports PEP 517 Python_ packaging.

Make the easy things easy and the hard things possible is an old motto from the
Perl_ community. Flit is entirely focused on the easy things part of that, and
leaves the hard things up to other tools.

Specifically, the easy things are pure Python_ packages with no build steps
(neither compiling C code, nor bundling Javascript, etc.). The vast majority of
packages on `PyPI <https://pypi.org/>`_ are like this: plain Python_ code, with
maybe some static data files like icons included.
endef

define fetch_flit_core_dist
$(call download_csum,$(flit_core_dist_url),\
                     $(FETCHDIR)/$(flit_core_dist_name),\
                     $(flit_core_dist_sum))
endef
$(call gen_fetch_rules,flit_core,flit_core_dist_name,fetch_flit_core_dist)

define xtract_flit_core
$(call rmrf,$(srcdir)/flit_core)
$(call untar,$(srcdir)/flit_core,\
             $(FETCHDIR)/$(flit_core_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flit_core,xtract_flit_core)

$(call gen_dir_rules,flit_core)

# $(1): targets base name / module name
define flit_core_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flit_core,stage-python)
$(call gen_check_deps,stage-flit_core,stage-pytest stage-testpath)

check_stage-flit_core = $(call flit_core_check_cmds,stage-flit_core)
$(call gen_python_module_rules,stage-flit_core,\
                               flit_core,\
                               $(stagedir),\
                               ,\
                               check_stage-flit_core)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-flit_core,stage-python)
$(call gen_check_deps,final-flit_core,stage-pytest stage-testpath)

check_final-flit_core = $(call flit_core_check_cmds,final-flit_core)
$(call gen_python_module_rules,final-flit_core,\
                               flit_core,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-flit_core)
