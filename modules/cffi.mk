# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

cffi_dist_url  := https://files.pythonhosted.org/packages/2b/a8/050ab4f0c3d4c1b8aaa805f70e26e84d0e27004907c5b8ecc1d31815f92a/cffi-1.15.1.tar.gz
cffi_dist_sum  := d400bfb9a37b1351253cb402671cea7e89bdecc294e8016a707f6d1d8ac934f9
cffi_dist_name := $(notdir $(cffi_dist_url))

define fetch_cffi_dist
$(call _download,$(cffi_dist_url),$(FETCHDIR)/$(cffi_dist_name).tmp)
cat $(FETCHDIR)/$(cffi_dist_name).tmp | \
	sha256sum --check --status <(echo "$(cffi_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(cffi_dist_name).tmp,\
          $(FETCHDIR)/$(cffi_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(cffi_dist_name)'
endef

# As fetch_cffi_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(cffi_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,cffi,cffi_dist_name,fetch_cffi_dist)

define xtract_cffi
$(call rmrf,$(srcdir)/cffi)
$(call untar,$(srcdir)/cffi,\
             $(FETCHDIR)/$(cffi_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cffi,xtract_cffi)

$(call gen_dir_rules,cffi)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cffi,stage-pycparser stage-libffi)

$(call gen_python_module_rules,stage-cffi,cffi,$(stagedir))
