# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

setuptools-rust_dist_url  := https://files.pythonhosted.org/packages/99/db/e4ecb483ffa194d632ed44bda32cb740e564789fed7e56c2be8e2a0e2aa6/setuptools-rust-1.5.2.tar.gz
setuptools-rust_dist_sum  := d8daccb14dc0eae1b6b6eb3ecef79675bd37b4065369f79c35393dd5c55652c7
setuptools-rust_dist_name := $(notdir $(setuptools-rust_dist_url))

define fetch_setuptools-rust_dist
$(call _download,$(setuptools-rust_dist_url),\
                 $(FETCHDIR)/$(setuptools-rust_dist_name).tmp)
cat $(FETCHDIR)/$(setuptools-rust_dist_name).tmp | \
	sha256sum --check --status <(echo "$(setuptools-rust_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(setuptools-rust_dist_name).tmp,\
          $(FETCHDIR)/$(setuptools-rust_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(setuptools-rust_dist_name)'
endef

# As fetch_setuptools-rust_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(setuptools-rust_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,setuptools-rust,\
                       setuptools-rust_dist_name,\
                       fetch_setuptools-rust_dist)

define xtract_setuptools-rust
$(call rmrf,$(srcdir)/setuptools-rust)
$(call untar,$(srcdir)/setuptools-rust,\
             $(FETCHDIR)/$(setuptools-rust_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,setuptools-rust,xtract_setuptools-rust)

$(call gen_dir_rules,setuptools-rust)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-setuptools-rust,\
                stage-setuptools stage-typing-extensions stage-semantic-version)

$(call gen_python_module_rules,stage-setuptools-rust,\
                               setuptools-rust,\
                               $(stagedir))
