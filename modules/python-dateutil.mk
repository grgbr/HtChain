################################################################################
# python-dateutil modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

python-dateutil_dist_url  := https://files.pythonhosted.org/packages/4c/c4/13b4776ea2d76c115c1d1b84579f3764ee6d57204f6be27119f13a61d0a9/python-dateutil-2.8.2.tar.gz
python-dateutil_dist_sum  := 6538858e4a3e2d1de1bf25b6d8b25e3a8d20bf60fb85e32d07ac491c90ce193e268bb5641371b8a79fb0f033a184bac9896b3bc643c1aca9ee9c6478286ac20c
python-dateutil_dist_name := $(notdir $(python-dateutil_dist_url))
python-dateutil_vers      := $(patsubst python-dateutil-%.tar.gz,%,$(python-dateutil_dist_name))
python-dateutil_brief     := Powerful extensions to the standard Python_ datetime module
python-dateutil_home      := https://github.com/dateutil/dateutil

define python-dateutil_desc
It features:

* computing of relative deltas (next month, next year, next monday, last week
  of month, etc);
* computing of relative deltas between two given date and/or datetime objects
* computing of dates based on very flexible recurrence rules, using a superset
  of the iCalendar specification. Parsing of RFC strings is supported as well.
* generic parsing of dates in almost any string format
* timezone (tzinfo) implementations for :manpage:`tzfile(5)` format files
  (:file:`/etc/localtime`, :file:`/usr/share/zoneinfo`, etc), TZ environment
  string (in all known formats), iCalendar format files, given ranges (with help
  from relative deltas), local machine timezone, fixed offset timezone, UTC
  timezone
* computing of Easter Sunday dates for any given year, using Western, Orthodox
  or Julian algorithms.
endef

define fetch_python-dateutil_dist
$(call download_csum,$(python-dateutil_dist_url),\
                     $(FETCHDIR)/$(python-dateutil_dist_name),\
                     $(python-dateutil_dist_sum))
endef
$(call gen_fetch_rules,python-dateutil,\
                       python-dateutil_dist_name,\
                       fetch_python-dateutil_dist)

define xtract_python-dateutil
$(call rmrf,$(srcdir)/python-dateutil)
$(call untar,$(srcdir)/python-dateutil,\
             $(FETCHDIR)/$(python-dateutil_dist_name),\
             --strip-components=1)
cd $(srcdir)/python-dateutil && \
patch -p1 < $(PATCHDIR)/python-dateutil-2.8.2-000-remove_zoneinfo.patch
endef
$(call gen_xtract_rules,python-dateutil,xtract_python-dateutil)

$(call gen_dir_rules,python-dateutil)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-python-dateutil,stage-six stage-wheel)

check_stage-python-dateutil = $(call python-dateutil_check_cmds,\
                                     stage-python-dateutil)
$(call gen_python_module_rules,stage-python-dateutil,\
                               python-dateutil,\
                               $(stagedir))
