################################################################################
# Babel modules
################################################################################

babel_dist_url  := https://files.pythonhosted.org/packages/ff/80/45b42203ecc32c8de281f52e3ec81cb5e4ef16127e9e8543089d8b1649fb/Babel-2.11.0.tar.gz
babel_dist_sum  := 526368dc5e44f2d93c52f2fcb544130eea6c6b7c78325bd56c6d9a6706890a4cd9daa1498d639aab65059801d87977da626e64585083c58c4b328001991eea0b
babel_dist_name := $(subst B,b,$(notdir $(babel_dist_url)))
babel_vers      := $(patsubst babel-%.tar.gz,%,$(babel_dist_name))
babel_brief     := Tools for internationalizing Python_ applications
babel_home      := https://babel.pocoo.org/

define babel_desc
Babel is composed of two major parts. First tools to build and work with gettext
message catalogs. Second a Python_ interface to the CLDR (Common Locale Data
Repository), providing access to various locale display names, localized number
and date formatting, etc...
endef

define fetch_babel_dist
$(call download_csum,$(babel_dist_url),\
                     $(FETCHDIR)/$(babel_dist_name),\
                     $(babel_dist_sum))
endef
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
