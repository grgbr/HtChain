# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

hypothesis_dist_url  := https://files.pythonhosted.org/packages/0b/a7/08f79b065d9b9cc2306aa1634c9cc5024e728d4629abb364b19c36e91afa/hypothesis-6.62.1.tar.gz
hypothesis_dist_sum  := 7d1e2f9871e6509662da317adf9b4aabd6b38280fb6c7930aa4f574d2ed25150
hypothesis_dist_name := $(notdir $(hypothesis_dist_url))

define fetch_hypothesis_dist
$(call _download,$(hypothesis_dist_url),$(FETCHDIR)/$(hypothesis_dist_name).tmp)
cat $(FETCHDIR)/$(hypothesis_dist_name).tmp | \
	sha256sum --check --status <(echo "$(hypothesis_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(hypothesis_dist_name).tmp,\
          $(FETCHDIR)/$(hypothesis_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(hypothesis_dist_name)'
endef

# As fetch_hypothesis_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(hypothesis_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,hypothesis,hypothesis_dist_name,fetch_hypothesis_dist)

define xtract_hypothesis
$(call rmrf,$(srcdir)/hypothesis)
$(call untar,$(srcdir)/hypothesis,\
             $(FETCHDIR)/$(hypothesis_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,hypothesis,xtract_hypothesis)

$(call gen_dir_rules,hypothesis)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-hypothesis,\
                stage-attrs stage-exceptiongroup stage-sortedcontainers)

$(call gen_python_module_rules,stage-hypothesis,hypothesis,$(stagedir))
