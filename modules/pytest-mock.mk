################################################################################
# pytest-mock Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest-mock_dist_url  := https://files.pythonhosted.org/packages/f6/2b/137a7db414aeaf3d753d415a2bc3b90aba8c5f61dff7a7a736d84b2ec60d/pytest-mock-3.10.0.tar.gz
pytest-mock_dist_sum  := 2ad6866d581a2999899e399ef5516d478a6172f52923f03703e3e3708229fb3b1178c91225b5cc90734c96abcb48fea517b11e0fc193da6fb592295395c14cd3
pytest-mock_dist_name := $(notdir $(pytest-mock_dist_url))
pytest-mock_vers      := $(patsubst pytest-mock-%.tar.gz,%,$(pytest-mock_dist_name))
pytest-mock_brief     := Thin-wrapper around mock_ for easier use with Pytest_
pytest-mock_home      := https://github.com/pytest-dev/pytest-mock/

define pytest-mock_desc
This plugin installs a "mocker" fixture which is a thin-wrapper around the
patching API provided by the excellent mock_ package, but with the benefit of
not having to worry about undoing patches at the end of a test.
endef

define fetch_pytest-mock_dist
$(call download_csum,$(pytest-mock_dist_url),\
                     $(pytest-mock_dist_name),\
                     $(pytest-mock_dist_sum))
endef
$(call gen_fetch_rules,pytest-mock,pytest-mock_dist_name,fetch_pytest-mock_dist)

define xtract_pytest-mock
$(call rmrf,$(srcdir)/pytest-mock)
$(call untar,$(srcdir)/pytest-mock,\
             $(FETCHDIR)/$(pytest-mock_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-mock,xtract_pytest-mock)

$(call gen_dir_rules,pytest-mock)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-mock,stage-mock stage-pytest)

$(call gen_python_module_rules,stage-pytest-mock,pytest-mock,$(stagedir))
