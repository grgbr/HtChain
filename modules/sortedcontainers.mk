################################################################################
# sortedcontainers Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

sortedcontainers_dist_url  := https://files.pythonhosted.org/packages/e8/c4/ba2f8066cceb6f23394729afe52f3bf7adec04bf9ed2c820b39e19299111/sortedcontainers-2.4.0.tar.gz
sortedcontainers_dist_sum  := 4c01522bc01367a27bb005f16a487c127459f949f3d9fa7094e559993ceb074b3f84dda167f300778f46bdc15669f05866b6117ff6c369ca9a561ae20ab7c53f
sortedcontainers_dist_name := $(notdir $(sortedcontainers_dist_url))
sortedcontainers_vers      := $(patsubst sortedcontainers-%.tar.gz,%,$(sortedcontainers_dist_name))
sortedcontainers_brief     := Python_ sorted container types: SortedList, SortedDict, and SortedSet
sortedcontainers_home      := http://www.grantjenks.com/docs/sortedcontainers/

define sortedcontainers_desc
Python_\'s standard library is great until you need a sorted container type.
Many will attest that you can get really far without one, but the moment you
really need a sorted list, dict, or set, you’re faced with a dozen different
implementations, most using C-extensions without great documentation and
benchmarking.
endef

define fetch_sortedcontainers_dist
$(call download_csum,$(sortedcontainers_dist_url),\
                     $(sortedcontainers_dist_name),\
                     $(sortedcontainers_dist_sum))
endef
$(call gen_fetch_rules,sortedcontainers,\
                       sortedcontainers_dist_name,\
                       fetch_sortedcontainers_dist)

define xtract_sortedcontainers
$(call rmrf,$(srcdir)/sortedcontainers)
$(call untar,$(srcdir)/sortedcontainers,\
             $(FETCHDIR)/$(sortedcontainers_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sortedcontainers,xtract_sortedcontainers)

$(call gen_dir_rules,sortedcontainers)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sortedcontainers,stage-wheel)

$(call gen_python_module_rules,stage-sortedcontainers,\
                               sortedcontainers,\
                               $(stagedir))
