################################################################################
# raven Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

raven_dist_url  := https://files.pythonhosted.org/packages/79/57/b74a86d74f96b224a477316d418389af9738ba7a63c829477e7a86dd6f47/raven-6.10.0.tar.gz
raven_dist_sum  := 37ca6d5953dc92b57b3bf4e2edb3947d41f33711d9babfc9eafb8712dc5923829f8810e5123e63749710aeecceb66e56bf8b5b60868f61d750704e20add3c747
raven_dist_name := $(notdir $(raven_dist_url))
raven_vers      := $(patsubst raven-%.tar.gz,%,$(raven_dist_name))
raven_brief     := Raven is a client for Sentry
raven_home      := https://github.com/getsentry/raven-python

define raven_desc
Raven is a Python_ client for `Sentry <https://getsentry.com>`_. It provides
full out-of-the-box support for many of the popular frameworks,
including Django, Flask_, and Pylons. Raven also includes drop-in support
for any WSGI-compatible web application.
endef

define fetch_raven_dist
$(call download_csum,$(raven_dist_url),\
                     $(raven_dist_name),\
                     $(raven_dist_sum))
endef
$(call gen_fetch_rules,raven,raven_dist_name,fetch_raven_dist)

define xtract_raven
$(call rmrf,$(srcdir)/raven)
$(call untar,$(srcdir)/raven,\
             $(FETCHDIR)/$(raven_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,raven,xtract_raven)

$(call gen_dir_rules,raven)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-raven,stage-flask stage-blinker)

$(call gen_python_module_rules,stage-raven,raven,$(stagedir))
