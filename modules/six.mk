################################################################################
# six Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

six_dist_url  := https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz
six_dist_sum  := 076fe31c8f03b0b52ff44346759c7dc8317da0972403b84dfe5898179f55acdba6c78827e0f8a53ff20afe8b76432c6fe0d655a75c24259d9acbaa4d9e8015c0
six_dist_name := $(notdir $(six_dist_url))
six_vers      := $(patsubst six-%.tar.gz,%,$(six_dist_name))
six_brief     := Python_ 2 and 3 compatibility library
six_home      := https://github.com/benjaminp/six

define six_desc
Six is a Python_ 2 and 3 compatibility library. It provides utility functions
for smoothing over the differences between the Python_ versions with the goal of
writing Python_ code that is compatible on both Python_ versions.
endef

define fetch_six_dist
$(call download_csum,$(six_dist_url),\
                     $(FETCHDIR)/$(six_dist_name),\
                     $(six_dist_sum))
endef
$(call gen_fetch_rules,six,six_dist_name,fetch_six_dist)

define xtract_six
$(call rmrf,$(srcdir)/six)
$(call untar,$(srcdir)/six,\
             $(FETCHDIR)/$(six_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,six,xtract_six)

$(call gen_dir_rules,six)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-six,stage-wheel)

$(call gen_python_module_rules,stage-six,six,$(stagedir))
