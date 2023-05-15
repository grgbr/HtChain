################################################################################
# pytest-timeout Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest-timeout_dist_url  := https://files.pythonhosted.org/packages/ef/30/37abbd50f86cb802cbcea50d68688438de1a7446d73c8ed8d048173b4b13/pytest-timeout-2.1.0.tar.gz
pytest-timeout_dist_sum  := 5750e5183669ed9b83fbb76bd7fc9fc1f5f6eef3d9b675dc44f6c7edfd2c6d15739d71e845ededaa192c93da73026ac3376a3295be9f7d3f3eac325660ce7bf3
pytest-timeout_dist_name := $(notdir $(pytest-timeout_dist_url))
pytest-timeout_vers      := $(patsubst pytest-timeout-%.tar.gz,%,$(pytest-timeout_dist_name))
pytest-timeout_brief     := Pytest_ plugin to abort hanging tests
pytest-timeout_home      := https://github.com/pytest-dev/pytest-timeout

define pytest-timeout_desc
This is a plugin which will terminate tests after a certain timeout.  When doing
so it will show a stack dump of all threads running at the time. This is useful
when running tests under a continuous integration server or simply if you don’t
know why the test suite hangs.

Note that while by default on POSIX systems Pytest_ will continue to execute the
tests after a test has timed, out this is not always possible. Often the only
sure way to interrupt a hanging test is by terminating the entire process.  As
this is a hard termination (``os._exit()``) it will result in no teardown, JUnit
XML output etc. But the plugin will ensure you will have the debugging output on
:file:`stderr` nevertheless, which is the most important part at this stage. See
below for detailed information on the timeout methods and their side-effects.
endef

define fetch_pytest-timeout_dist
$(call download_csum,$(pytest-timeout_dist_url),\
                     $(pytest-timeout_dist_name),\
                     $(pytest-timeout_dist_sum))
endef
$(call gen_fetch_rules,pytest-timeout,\
                       pytest-timeout_dist_name,\
                       fetch_pytest-timeout_dist)

define xtract_pytest-timeout
$(call rmrf,$(srcdir)/pytest-timeout)
$(call untar,$(srcdir)/pytest-timeout,\
             $(FETCHDIR)/$(pytest-timeout_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-timeout,xtract_pytest-timeout)

$(call gen_dir_rules,pytest-timeout)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-timeout,stage-pytest)

$(call gen_python_module_rules,stage-pytest-timeout,\
                               pytest-timeout,\
                               $(stagedir))
