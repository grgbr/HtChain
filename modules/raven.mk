# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

raven_dist_url  := https://files.pythonhosted.org/packages/79/57/b74a86d74f96b224a477316d418389af9738ba7a63c829477e7a86dd6f47/raven-6.10.0.tar.gz
raven_dist_sum  := 3fa6de6efa2493a7c827472e984ce9b020797d0da16f1db67197bcc23c8fae54
raven_dist_name := $(notdir $(raven_dist_url))

define fetch_raven_dist
$(call _download,$(raven_dist_url),\
                 $(FETCHDIR)/$(raven_dist_name).tmp)
cat $(FETCHDIR)/$(raven_dist_name).tmp | \
	sha256sum --check --status <(echo "$(raven_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(raven_dist_name).tmp,\
          $(FETCHDIR)/$(raven_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(raven_dist_name)'
endef

# As fetch_raven_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(raven_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,raven,\
                       raven_dist_name,\
                       fetch_raven_dist)

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
