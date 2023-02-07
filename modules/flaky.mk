################################################################################
# flaky Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

flaky_dist_url  := https://files.pythonhosted.org/packages/d5/dd/422c7c5c8c9f4982f3045c73d0571ed4a4faa5754699cc6a6384035fbd80/flaky-3.7.0.tar.gz
flaky_dist_sum  := b399f6e1323d6ca341803ac6f1eb318bf24dc37182d0b49b89bb81b9466dd36271ad6dbb9f48ea6fa4760ee631f1482bb6f49c64f4d4520c40634089c1b64f9a
flaky_dist_name := $(notdir $(flaky_dist_url))
flaky_vers      := $(patsubst flaky-%.tar.gz,%,$(flaky_dist_name))
flaky_brief     := Plugin for ``nose`` or ``py.test`` that automatically reruns flaky tests
flaky_home      := https://github.com/box/flaky

define flaky_desc
Flaky is a plugin for ``nose`` or ``py.test`` that automatically reruns flaky
tests.

Ideally, tests reliably pass or fail, but sometimes test fixtures must rely on
components that aren't 100% reliable. With flaky, instead of removing those
tests or marking them to ``@skip``, they can be automatically retried.
endef

define fetch_flaky_dist
$(call download_csum,$(flaky_dist_url),\
                     $(FETCHDIR)/$(flaky_dist_name),\
                     $(flaky_dist_sum))
endef
$(call gen_fetch_rules,flaky,flaky_dist_name,fetch_flaky_dist)

define xtract_flaky
$(call rmrf,$(srcdir)/flaky)
$(call untar,$(srcdir)/flaky,\
             $(FETCHDIR)/$(flaky_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flaky,xtract_flaky)

$(call gen_dir_rules,flaky)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flaky,stage-wheel)

$(call gen_python_module_rules,stage-flaky,flaky,$(stagedir))
