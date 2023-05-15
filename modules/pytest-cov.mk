################################################################################
# pytest-cov Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest-cov_dist_url  := https://files.pythonhosted.org/packages/ea/70/da97fd5f6270c7d2ce07559a19e5bf36a76f0af21500256f005a69d9beba/pytest-cov-4.0.0.tar.gz
pytest-cov_dist_sum  := fb993be4d86b29a44e4f2ccd2309d99ab9fe8e6b291abbc2a8a3fc8b36479491165a242a20bfa9886dfd296fcc827da9984b556fdbe9a3ac496ac5b6ba379012
pytest-cov_dist_name := $(notdir $(pytest-cov_dist_url))
pytest-cov_vers      := $(patsubst pytest-cov-%.tar.gz,%,$(pytest-cov_dist_name))
pytest-cov_brief     := ``py.test`` plugin to produce coverage reports for Python_
pytest-cov_home      := https://github.com/pytest-dev/pytest-cov

define pytest-cov_desc
This py.test plugin produces coverage reports. It supports both centralised and
distributed testing across multiple hosts. It can run parallel tests on
different platforms, architectures, and Python_ versions.
It supports coverage of subprocesses and can produce reports in text, HTML, XML
and annotated source code.
endef

define fetch_pytest-cov_dist
$(call download_csum,$(pytest-cov_dist_url),\
                     $(pytest-cov_dist_name),\
                     $(pytest-cov_dist_sum))
endef
$(call gen_fetch_rules,pytest-cov,pytest-cov_dist_name,fetch_pytest-cov_dist)

define xtract_pytest-cov
$(call rmrf,$(srcdir)/pytest-cov)
$(call untar,$(srcdir)/pytest-cov,\
             $(FETCHDIR)/$(pytest-cov_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-cov,xtract_pytest-cov)

$(call gen_dir_rules,pytest-cov)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-cov,stage-pytest stage-coverage)

$(call gen_python_module_rules,stage-pytest-cov,pytest-cov,$(stagedir))
