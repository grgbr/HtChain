# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pytest-freezegun_dist_url  := https://files.pythonhosted.org/packages/f0/e3/c39d7c3d3afef5652f19323f3483267d7e6b0d9911c3867e10d6e2d3c9ae/pytest-freezegun-0.4.2.zip
pytest-freezegun_dist_sum  := 19c82d5633751bf3ec92caa481fb5cffaac1787bd485f0df6436fd6242176949
pytest-freezegun_dist_name := $(notdir $(pytest-freezegun_dist_url))

define fetch_pytest-freezegun_dist
$(call _download,$(pytest-freezegun_dist_url),\
                 $(FETCHDIR)/$(pytest-freezegun_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-freezegun_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-freezegun_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-freezegun_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-freezegun_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-freezegun_dist_name)'
endef

# As fetch_pytest-freezegun_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-freezegun_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-freezegun,\
                       pytest-freezegun_dist_name,\
                       fetch_pytest-freezegun_dist)

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
