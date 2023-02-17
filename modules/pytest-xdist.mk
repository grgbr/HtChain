################################################################################
# pytest-xdist Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest-xdist_dist_url  := https://files.pythonhosted.org/packages/0d/e5/f7ece02dc1b4bc24a3e37be6a78251e03fff4193126d7ce126c450644696/pytest-xdist-3.1.0.tar.gz
pytest-xdist_dist_sum  := 884cdd85754b36338666cbdd71575ef18465730cfc4ab7333b93aa46823c1dc33e8055117241f4c87e1b8c82492881cc0f91ef1bb2ddc164aa00bfa1e5e2d245
pytest-xdist_dist_name := $(notdir $(pytest-xdist_dist_url))
pytest-xdist_vers      := $(patsubst pytest-xdist-%.tar.gz,%,$(pytest-xdist_dist_name))
pytest-xdist_brief     := xdist plugin for Pytest_
pytest-xdist_home      := https://github.com/pytest-dev/pytest-xdist

define pytest-xdist_desc
The pytest-xdist plugin extends Pytest_ with some unique test execution modes.

Looponfail
   Run your tests repeatedly in a subprocess. After each run Pytest_ waits until
   a file in your project changes and then re-runs the previously failing tests.
   This is repeated until all tests pass after which again a full run is
   performed.

Load-balancing
   If you have multiple CPUs or hosts you can use those for a combined test run.
   This allows one to speed up development or to use special resources of remote
   machines.

Multi-Platform coverage
   You can specify different Python_ interpreters or different platforms and run
   tests in parallel on all of them.

Before running tests remotely, Pytest_ efficiently synchronizes your program
source code to the remote place. All test results are reported back and
displayed to your local test session. You may specify different Python_ versions
and interpreters.
endef

define fetch_pytest-xdist_dist
$(call download_csum,$(pytest-xdist_dist_url),\
                     $(FETCHDIR)/$(pytest-xdist_dist_name),\
                     $(pytest-xdist_dist_sum))
endef
$(call gen_fetch_rules,pytest-xdist,\
                       pytest-xdist_dist_name,\
                       fetch_pytest-xdist_dist)

define xtract_pytest-xdist
$(call rmrf,$(srcdir)/pytest-xdist)
$(call untar,$(srcdir)/pytest-xdist,\
             $(FETCHDIR)/$(pytest-xdist_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-xdist,xtract_pytest-xdist)

$(call gen_dir_rules,pytest-xdist)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-xdist,stage-pytest stage-execnet)
$(call gen_python_module_rules,stage-pytest-xdist,pytest-xdist,$(stagedir))
