################################################################################
# Pytest Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest_dist_url  := https://files.pythonhosted.org/packages/0b/21/055f39bf8861580b43f845f9e8270c7786fe629b2f8562ff09007132e2e7/pytest-7.2.0.tar.gz
pytest_dist_sum  := a16b034c8522f0aa6ee9541b07b79be713565a6e755ab0489b38c2b0a0ed9f7857c87f952ff24c199a2e4c0d71ee26e918dd06abfe994d30ac90e32ae3e8c4d1
pytest_dist_name := $(notdir $(pytest_dist_url))
pytest_vers      := $(patsubst pytest-%.tar.gz,%,$(pytest_dist_name))
pytest_brief     := Simple, powerful testing in Python_
pytest_home      := https://docs.pytest.org/en/latest/

define pytest_desc
This testing tool has for objective to allow the developers to limit the
boilerplate code around the tests, promoting the use of built-in mechanisms such
as the ``assert`` keyword.
endef

define fetch_pytest_dist
$(call download_csum,$(pytest_dist_url),\
                     $(pytest_dist_name),\
                     $(pytest_dist_sum))
endef
$(call gen_fetch_rules,pytest,pytest_dist_name,fetch_pytest_dist)

define xtract_pytest
$(call rmrf,$(srcdir)/pytest)
$(call untar,$(srcdir)/pytest,\
             $(FETCHDIR)/$(pytest_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest,xtract_pytest)

$(call gen_dir_rules,pytest)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest,stage-attrs \
                             stage-exceptiongroup \
                             stage-iniconfig)

$(call gen_python_module_rules,stage-pytest,pytest,$(stagedir))
