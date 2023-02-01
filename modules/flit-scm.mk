# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

flit-scm_dist_url  := https://files.pythonhosted.org/packages/e2/99/961b062461652435b6ad9042d2ffdd75e327b36936987c2073aa784334d5/flit_scm-1.7.0.tar.gz
flit-scm_dist_sum  := 961bd6fb24f31bba75333c234145fff88e6de0a90fc0f7e5e7c79deca69f6bb2
flit-scm_dist_name := $(notdir $(flit-scm_dist_url))

define fetch_flit-scm_dist
$(call _download,$(flit-scm_dist_url),$(FETCHDIR)/$(flit-scm_dist_name).tmp)
cat $(FETCHDIR)/$(flit-scm_dist_name).tmp | \
	sha256sum --check --status <(echo "$(flit-scm_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(flit-scm_dist_name).tmp,\
          $(FETCHDIR)/$(flit-scm_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(flit-scm_dist_name)'
endef

# As fetch_flit-scm_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(flit-scm_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,flit-scm,flit-scm_dist_name,fetch_flit-scm_dist)

define xtract_flit-scm
$(call rmrf,$(srcdir)/flit-scm)
$(call untar,$(srcdir)/flit-scm,\
             $(FETCHDIR)/$(flit-scm_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,flit-scm,xtract_flit-scm)

$(call gen_dir_rules,flit-scm)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-flit-scm,stage-setuptools-scm)

$(call gen_python_module_rules,stage-flit-scm,flit-scm,$(stagedir))
