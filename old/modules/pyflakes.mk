pyflakes_dist_url  := https://files.pythonhosted.org/packages/07/92/f0cb5381f752e89a598dd2850941e7f570ac3cb8ea4a344854de486db152/pyflakes-2.5.0.tar.gz
pyflakes_dist_sum  := 491feb020dca48ccc562a8c0cbe8df07ee13078df59813b83959cbdada312ea3
pyflakes_dist_name := $(notdir $(pyflakes_dist_url))

define fetch_pyflakes_dist
$(call _download,$(pyflakes_dist_url),\
                 $(FETCHDIR)/$(pyflakes_dist_name).tmp)
cat $(FETCHDIR)/$(pyflakes_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pyflakes_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pyflakes_dist_name).tmp,\
          $(FETCHDIR)/$(pyflakes_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pyflakes_dist_name)'
endef

# As fetch_pyflakes_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pyflakes_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pyflakes,\
                       pyflakes_dist_name,\
                       fetch_pyflakes_dist)

define xtract_pyflakes
$(call rmrf,$(srcdir)/pyflakes)
$(call untar,$(srcdir)/pyflakes,\
             $(FETCHDIR)/$(pyflakes_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pyflakes,xtract_pyflakes)

$(call gen_dir_rules,pyflakes)

# $(1): targets base name / module name
#
# Make PYTHONPATH pointing to build directory to prevent from using previously
# installed pyflakes. This is required to workaround the following error:
#     import file mismatch:
#     imported module ...
#     ...
#     which is not the same as the test file we want to collect:
#     ...
#     HINT: remove __pycache__ / .pyc files and/or use a unique basename ...
define pyflakes_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pyflakes,stage-python)
$(call gen_check_deps,stage-pyflakes,stage-pytest)

check_stage-pyflakes = $(call pyflakes_check_cmds,stage-pyflakes)
$(call gen_python_module_rules,stage-pyflakes,\
                               pyflakes,\
                               $(stagedir),\
                               ,\
                               check_stage-pyflakes)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pyflakes,stage-python)
$(call gen_check_deps,final-pyflakes,stage-pytest)

check_final-pyflakes = $(call pyflakes_check_cmds,final-pyflakes)
$(call gen_python_module_rules,final-pyflakes,pyflakes,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pyflakes)
