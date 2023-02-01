# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

trustme_dist_url  := https://files.pythonhosted.org/packages/34/8e/66203d0c8c4557db28772678359e0878610624db8438b1ed9361ceeaad1d/trustme-0.9.0.tar.gz
trustme_dist_sum  := 5e07b23d70ceed64f3bb36ae4b9abc52354c16c98d45ab037bee2b5fbffe586c
trustme_dist_name := $(notdir $(trustme_dist_url))

define fetch_trustme_dist
$(call _download,$(trustme_dist_url),$(FETCHDIR)/$(trustme_dist_name).tmp)
cat $(FETCHDIR)/$(trustme_dist_name).tmp | \
	sha256sum --check --status <(echo "$(trustme_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(trustme_dist_name).tmp,\
          $(FETCHDIR)/$(trustme_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(trustme_dist_name)'
endef

# As fetch_trustme_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(trustme_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,trustme,trustme_dist_name,fetch_trustme_dist)

define xtract_trustme
$(call rmrf,$(srcdir)/trustme)
$(call untar,$(srcdir)/trustme,\
             $(FETCHDIR)/$(trustme_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,trustme,xtract_trustme)

$(call gen_dir_rules,trustme)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-trustme,stage-cryptography stage-idna)

$(call gen_python_module_rules,stage-trustme,trustme,$(stagedir))
