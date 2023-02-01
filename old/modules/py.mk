py_dist_url  := https://files.pythonhosted.org/packages/98/ff/fec109ceb715d2a6b4c4a85a61af3b40c723a961e8828319fbcb15b868dc/py-1.11.0.tar.gz
py_dist_sum  := 51c75c4126074b472f746a24399ad32f6053d1b34b68d2fa41e558e6f4a98719
py_dist_name := $(notdir $(py_dist_url))

define fetch_py_dist
$(call _download,$(py_dist_url),$(FETCHDIR)/$(py_dist_name).tmp)
cat $(FETCHDIR)/$(py_dist_name).tmp | \
	sha256sum --check --status <(echo "$(py_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(py_dist_name).tmp,\
          $(FETCHDIR)/$(py_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(py_dist_name)'
endef

# As fetch_py_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(py_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,py,py_dist_name,fetch_py_dist)

define xtract_py
$(call rmrf,$(srcdir)/py)
$(call untar,$(srcdir)/py,\
             $(FETCHDIR)/$(py_dist_name),\
             --strip-components=1)
cd $(srcdir)/py && \
patch -p1 < $(PATCHDIR)/py-1.11.0-000-fix_pytest4.patch
endef
$(call gen_xtract_rules,py,xtract_py)

$(call gen_dir_rules,py)

# $(1): targets base name / module name
#
# Disable testing/code/test_excinfo.py since not compatible with pytest>=5.3.
# See issue related to _write_source attribute of TerminalWriter:
#     https://github.com/pytest-dev/pytest/issues/7041
define py_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --deselect testing/code/test_excinfo.py
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-py,stage-setuptools-scm)
$(call gen_check_deps,stage-py,stage-pytest stage-attrs)

check_stage-py = $(call py_check_cmds,stage-py)
$(call gen_python_module_rules,stage-py,py,$(stagedir),,check_stage-py)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-py,stage-setuptools-scm)
$(call gen_check_deps,final-py,stage-pytest stage-attrs)

check_final-py = $(call py_check_cmds,final-py)
$(call gen_python_module_rules,final-py,py,\
                                        $(PREFIX),\
                                        $(finaldir),\
                                        check_final-py)
