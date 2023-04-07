################################################################################
# pytz Python modules
################################################################################

pytz_dist_url  := https://files.pythonhosted.org/packages/03/3e/dc5c793b62c60d0ca0b7e58f1fdd84d5aaa9f8df23e7589b39cc9ce20a03/pytz-2022.7.1.tar.gz
pytz_dist_sum  := c70b9ef9c6e6a7dd50fc80a58bf068af33dbcdc83c3f2f44b0726e696927e17d843f2f0438392b6f34738a63aa51c5025e6aa4bcbb9e43400b9d68334ff05c18
pytz_dist_name := $(notdir $(pytz_dist_url))
pytz_vers      := $(patsubst pytz-%.tar.gz,%,$(pytz_dist_name))
pytz_brief     := World timezone definitions, modern and historical for Python_
pytz_home      := http://pythonhosted.org/pytz

define pytz_desc
pytz brings the Olson tz database into Python_. This library allows accurate and
cross platform timezone calculations using Python_ 2.4 or higher. It also solves
the issue of ambiguous times at the end of daylight saving time, which you can
read more about in the Python_ Library Reference (datetime.tzinfo).

Almost all of the Olson timezones are supported.

This library differs from the documented Python_ API for tzinfo implementations;
if you want to create local wallclock times you need to use the ``localize()``
method documented in this document. In addition, if you perform date arithmetic
on local times that cross DST boundaries, the result may be in an incorrect
timezone (ie. subtract 1 minute from 2002-10-27 1:00 EST and you get 2002-10-27
0:59 EST instead of the correct 2002-10-27 1:59 EDT). A ``normalize()`` method
is provided to correct this. Unfortunately these issues cannot be resolved
without modifying the Python_ datetime implementation (see PEP-431).
endef

define fetch_pytz_dist
$(call download_csum,$(pytz_dist_url),\
                     $(FETCHDIR)/$(pytz_dist_name),\
                     $(pytz_dist_sum))
endef
$(call gen_fetch_rules,pytz,pytz_dist_name,fetch_pytz_dist)

define xtract_pytz
$(call rmrf,$(srcdir)/pytz)
$(call untar,$(srcdir)/pytz,\
             $(FETCHDIR)/$(pytz_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytz,xtract_pytz)

$(call gen_dir_rules,pytz)

# $(1): targets base name / module name
define pytz_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-pytz = $(call pytz_check_cmds,stage-pytz)

$(call gen_deps,stage-pytz,stage-wheel stage-flit_core)
$(call gen_check_deps,stage-pytz,stage-pytest)
$(call gen_python_module_rules,stage-pytz,pytz,$(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-pytz = $(call pytz_check_cmds,final-pytz)

$(call gen_deps,final-pytz,stage-wheel stage-flit_core)
$(call gen_check_deps,final-pytz,stage-pytest)
$(call gen_python_module_rules,final-pytz,pytz,$(PREFIX),$(finaldir))
