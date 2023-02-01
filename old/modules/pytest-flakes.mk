pytest-flakes_dist_url  := https://files.pythonhosted.org/packages/b5/8c/7d4bb3475c373b16ece7a94bd0e33ec045076c9189ed4022299679885179/pytest-flakes-4.0.5.tar.gz
pytest-flakes_dist_sum  := 953134e97215ae31f6879fbd7368c18d43f709dc2fab5b7777db2bb2bac3a924
pytest-flakes_dist_name := $(notdir $(pytest-flakes_dist_url))

define fetch_pytest-flakes_dist
$(call _download,$(pytest-flakes_dist_url),\
                 $(FETCHDIR)/$(pytest-flakes_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-flakes_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-flakes_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-flakes_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-flakes_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-flakes_dist_name)'
endef

# As fetch_pytest-flakes_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-flakes_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-flakes,\
                       pytest-flakes_dist_name,\
                       fetch_pytest-flakes_dist)

define xtract_pytest-flakes
$(call rmrf,$(srcdir)/pytest-flakes)
$(call untar,$(srcdir)/pytest-flakes,\
             $(FETCHDIR)/$(pytest-flakes_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-flakes,xtract_pytest-flakes)

$(call gen_dir_rules,pytest-flakes)

# $(1): targets base name / module name
define pytest-flakes_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-flakes,stage-pyflakes stage-pytest)
$(call gen_check_deps,stage-pytest-flakes,stage-pytest-flakes)

check_stage-pytest-flakes = $(call pytest-flakes_check_cmds,stage-pytest-flakes)
$(call gen_python_module_rules,stage-pytest-flakes,\
                               pytest-flakes,\
                               $(stagedir),\
                               ,\
                               check_stage-pytest-flakes)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytest-flakes,stage-pyflakes stage-pytest)
$(call gen_check_deps,final-pytest-flakes,stage-pytest-flakes)

check_final-pytest-flakes = $(call pytest-flakes_check_cmds,final-pytest-flakes)
$(call gen_python_module_rules,final-pytest-flakes,pytest-flakes,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-pytest-flakes)
