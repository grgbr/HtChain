################################################################################
# wheel Python modules
#
# Required to build some python modules from source.
################################################################################

wheel_dist_url  := https://files.pythonhosted.org/packages/a2/b8/6a06ff0f13a00fc3c3e7d222a995526cbca26c1ad107691b6b1badbbabf1/wheel-0.38.4.tar.gz
wheel_dist_sum  := 46d0589868cdc653b231bd3adb63c1e1e65c2d4d2a7696c2a64b6dc42b2512496af4ee28e5cea66d4dcc6c610ce2d567792f044929dea8ba3e22d2f8d6cafe61
wheel_dist_name := $(notdir $(wheel_dist_url))
wheel_vers      := $(patsubst wheel-%.tar.gz,%,$(wheel_dist_name))
wheel_brief     := Built-package format for Python_
wheel_home      := https://github.com/pypa/wheel

define wheel_desc
A wheel is a ZIP-format archive with a specially formatted filename and the
:file:`.whl` extension. It is designed to contain all the files for a PEP 376
compatible install in a way that is very close to the on-disk format.

The wheel project provides a ``bdist_wheel`` command for setuptools. Wheel files
can be installed with :command:`pip`.
endef

define fetch_wheel_dist
$(call download_csum,$(wheel_dist_url),\
                     $(wheel_dist_name),\
                     $(wheel_dist_sum))
endef
$(call gen_fetch_rules,wheel,wheel_dist_name,fetch_wheel_dist)

define xtract_wheel
$(call rmrf,$(srcdir)/wheel)
$(call untar,$(srcdir)/wheel,\
             $(FETCHDIR)/$(wheel_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,wheel,xtract_wheel)

$(call gen_dir_rules,wheel)

# $(1): targets base name / module name
#
# Disable MacOS related tests
define wheel_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    HOME="$(builddir)/$(strip $(1))/.home" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose --deselect tests/test_macosx_libfile.py
endef

################################################################################
# Staging definitions
################################################################################

check_stage-wheel = $(call wheel_check_cmds,stage-wheel)

$(call gen_deps,stage-wheel,stage-python)
$(call gen_check_deps,stage-wheel,stage-pytest)
$(call gen_python_module_rules,stage-wheel,wheel,$(stagedir))

################################################################################
# Final definitions
################################################################################

final-wheel_shebang_fixups := bin/wheel

define install_final-wheel
$(call python_module_install_cmds,final-wheel,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-wheel_shebang_fixups)),\
       $(PREFIX)/bin/python)
endef

check_final-wheel = $(call wheel_check_cmds,final-wheel)

$(call gen_deps,final-wheel,stage-python)
$(call gen_check_deps,final-wheel,stage-pytest)
$(call gen_python_module_rules,final-wheel,wheel,$(PREFIX),$(finaldir))
