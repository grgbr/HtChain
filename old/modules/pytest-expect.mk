pytest-expect_dist_url  := https://files.pythonhosted.org/packages/8b/3d/c5fcbb8a693dcde00ecc3d69639b2b2b3f385b305bc76a06f94f1030b2dc/pytest-expect-1.1.0.tar.gz
pytest-expect_dist_sum  := 36b4462704450798197d090809a05f4e13649d9cba9acdc557ce9517da1fd847
pytest-expect_dist_name := $(notdir $(pytest-expect_dist_url))

define fetch_pytest-expect_dist
$(call _download,$(pytest-expect_dist_url),$(FETCHDIR)/$(pytest-expect_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-expect_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-expect_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-expect_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-expect_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-expect_dist_name)'
endef

# As fetch_pytest-expect_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-expect_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-expect,pytest-expect_dist_name,fetch_pytest-expect_dist)

define xtract_pytest-expect
$(call rmrf,$(srcdir)/pytest-expect)
$(call untar,$(srcdir)/pytest-expect,\
             $(FETCHDIR)/$(pytest-expect_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-expect,xtract_pytest-expect)

$(call gen_dir_rules,pytest-expect)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-expect,stage-pytest stage-u-msgpack)

$(call gen_python_module_rules,stage-pytest-expect,\
                               pytest-expect,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pytest-expect,stage-pytest stage-u-msgpack)

$(call gen_python_module_rules,final-pytest-expect,\
                               pytest-expect,\
                               $(PREFIX),\
                               $(finaldir))
