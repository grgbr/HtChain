################################################################################
# coverage python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

coverage_dist_url  := https://files.pythonhosted.org/packages/84/b3/992a6b222b14c99e6d4aa9f448c670a5f614648597499de6ddc11be839e3/coverage-7.0.5.tar.gz
coverage_dist_sum  := d199d710cdfac5c6cde79224b4a27d6b88a0e0c504eff7ad5700e9fb1f5cc8e1e9359dcc12f6c447a7ee6cd680feeb89f70ad68574a739c55a6d09b22017df06
coverage_dist_name := $(notdir $(coverage_dist_url))
coverage_vers      := $(patsubst coverage-%.tar.gz,%,$(coverage_dist_name))
coverage_brief     := Code coverage tool for Python_
coverage_home      := https://github.com/nedbat/coveragepy

define coverage_desc
Coverage.py is a tool for measuring code coverage of Python_ programs.  It
monitors your program, noting which parts of the code have been executed, then
analyzes the source to identify code that could have been executed but was not.

Coverage measurement is typically used to gauge the effectiveness of tests. It
can show which parts of your code are being exercised by tests, and which are
not.
endef

define fetch_coverage_dist
$(call download_csum,$(coverage_dist_url),\
                     $(coverage_dist_name),\
                     $(coverage_dist_sum))
endef
$(call gen_fetch_rules,coverage,coverage_dist_name,fetch_coverage_dist)

define xtract_coverage
$(call rmrf,$(srcdir)/coverage)
$(call untar,$(srcdir)/coverage,\
             $(FETCHDIR)/$(coverage_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,coverage,xtract_coverage)

$(call gen_dir_rules,coverage)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-coverage,stage-wheel)

$(call gen_python_module_rules,stage-coverage,coverage,$(stagedir))
