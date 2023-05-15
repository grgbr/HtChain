################################################################################
# pytest-freezegun Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest-freezegun_dist_url  := https://files.pythonhosted.org/packages/f0/e3/c39d7c3d3afef5652f19323f3483267d7e6b0d9911c3867e10d6e2d3c9ae/pytest-freezegun-0.4.2.zip
pytest-freezegun_dist_sum  := 0f1f8e75081ddc285f1fe5e985d434ad396cdf80efc585f9957462ccb1eebe23f3e2a260f141a637d2d523119ac9be498ce36900fbaabfeaa60590ca64788c29
pytest-freezegun_dist_name := $(notdir $(pytest-freezegun_dist_url))
pytest-freezegun_vers      := $(patsubst pytest-freezegun-%.zip,%,$(pytest-freezegun_dist_name))
pytest-freezegun_brief     := Pytest_ plugin for Freezegun_
pytest-freezegun_home      := https://github.com/ktosiek/pytest-freezegun

define fetch_pytest-freezegun_dist
$(call download_csum,$(pytest-freezegun_dist_url),\
                     $(pytest-freezegun_dist_name),\
                     $(pytest-freezegun_dist_sum))
endef
$(call gen_fetch_rules,pytest-freezegun,pytest-freezegun_dist_name,fetch_pytest-freezegun_dist)

define xtract_pytest-freezegun
$(call rmrf,$(srcdir)/pytest-freezegun)
$(call unzip,$(srcdir)/pytest-freezegun.tmp,\
             $(FETCHDIR)/$(pytest-freezegun_dist_name))
$(call mv,$(srcdir)/pytest-freezegun.tmp/$(basename $(pytest-freezegun_dist_name)),\
          $(srcdir)/pytest-freezegun)
$(call rmrf,$(srcdir)/pytest-freezegun.tmp)
endef
$(call gen_xtract_rules,pytest-freezegun,xtract_pytest-freezegun)

$(call gen_dir_rules,pytest-freezegun)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-freezegun,stage-pytest stage-freezegun)

$(call gen_python_module_rules,stage-pytest-freezegun,\
                               pytest-freezegun,\
                               $(stagedir))
