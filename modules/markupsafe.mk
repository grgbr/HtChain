################################################################################
# markupsafe Python modules
################################################################################

markupsafe_dist_url  := https://files.pythonhosted.org/packages/95/7e/68018b70268fb4a2a605e2be44ab7b4dd7ce7808adae6c5ef32e34f4b55a/MarkupSafe-2.1.2.tar.gz
markupsafe_dist_sum  := 84dbeddaf2df713b3cce94eb64876fea8f80c608e25130c18e4691be2b1dea56df8b772d26c0caca88231ef795125eb9678210c33bf20518c18e3047912ddb4b
markupsafe_vers      := $(patsubst MarkupSafe-%.tar.gz,%,$(notdir $(markupsafe_dist_url)))
markupsafe_dist_name := markupsafe-$(markupsafe_vers).tar.gz
markupsafe_brief     := HTML/XHTML/XML string library for Python_
markupsafe_home      := https://palletsprojects.com/p/markupsafe/

define markupsafe_desc
MarkupSafe is a Python_ library implementing a unicode subclass that is aware of
HTML escaping rules. It can be used to implement automatic string escaping.
endef

define fetch_markupsafe_dist
$(call download_csum,$(markupsafe_dist_url),\
                     $(FETCHDIR)/$(markupsafe_dist_name),\
                     $(markupsafe_dist_sum))
endef
$(call gen_fetch_rules,markupsafe,markupsafe_dist_name,fetch_markupsafe_dist)

define xtract_markupsafe
$(call rmrf,$(srcdir)/markupsafe)
$(call untar,$(srcdir)/markupsafe,\
             $(FETCHDIR)/$(markupsafe_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,markupsafe,xtract_markupsafe)

$(call gen_dir_rules,markupsafe)

# $(1): targets base name / module name
define markupsafe_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-markupsafe,stage-wheel)
$(call gen_check_deps,stage-markupsafe,stage-markupsafe stage-pytest)

check_stage-markupsafe = $(call markupsafe_check_cmds,stage-markupsafe)
$(call gen_python_module_rules,stage-markupsafe,\
                               markupsafe,\
                               $(stagedir),\
                               ,\
                               check_stage-markupsafe)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-markupsafe,stage-wheel)
$(call gen_check_deps,final-markupsafe,stage-markupsafe stage-pytest)

check_final-markupsafe = $(call markupsafe_check_cmds,final-markupsafe)
$(call gen_python_module_rules,final-markupsafe,markupsafe,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-markupsafe)
