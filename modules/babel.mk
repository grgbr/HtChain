babel_dist_url  := https://files.pythonhosted.org/packages/ff/80/45b42203ecc32c8de281f52e3ec81cb5e4ef16127e9e8543089d8b1649fb/Babel-2.11.0.tar.gz
babel_dist_sum  := 5ef4b3226b0180dedded4229651c8b0e1a3a6a2837d45a073272f313e4cf97f6
babel_dist_name := $(notdir $(babel_dist_url))

define fetch_babel_dist
$(call _download,$(babel_dist_url),$(FETCHDIR)/$(babel_dist_name).tmp)
cat $(FETCHDIR)/$(babel_dist_name).tmp | \
	sha256sum --check --status <(echo "$(babel_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(babel_dist_name).tmp,\
          $(FETCHDIR)/$(babel_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(babel_dist_name)'
endef

# As fetch_babel_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(babel_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,babel,babel_dist_name,fetch_babel_dist)

define xtract_babel
$(call rmrf,$(srcdir)/babel)
$(call untar,$(srcdir)/babel,\
             $(FETCHDIR)/$(babel_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,babel,xtract_babel)

$(call gen_dir_rules,babel)

# $(1): targets base name / module name
define babel_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-babel,stage-pytz)
$(call gen_check_deps,stage-babel,stage-pytest stage-freezegun)

check_stage-babel = $(call babel_check_cmds,stage-babel)
$(call gen_python_module_rules,stage-babel,\
                               babel,\
                               $(stagedir),\
                               ,\
                               check_stage-babel)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-babel,stage-pytz)
$(call gen_check_deps,final-babel,stage-pytest stage-freezegun)

check_final-babel = $(call babel_check_cmds,final-babel)
$(call gen_python_module_rules,final-babel,\
                               babel,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-babel)
