################################################################################
# cffi modules
################################################################################

# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

cffi_dist_url  := https://files.pythonhosted.org/packages/2b/a8/050ab4f0c3d4c1b8aaa805f70e26e84d0e27004907c5b8ecc1d31815f92a/cffi-1.15.1.tar.gz
cffi_dist_sum  := e99cafcb029076abc29e435b490fa0573ee2856f4051b7ca8a5b38cd125d56dd9dae8b189f59ceb3d728a675da8ee83239e09e19f8b0feeddea4b186ab5173a5
cffi_dist_name := $(notdir $(cffi_dist_url))
cffi_vers      := $(patsubst cffi-%.tar.gz,%,$(cffi_dist_name))
cffi_brief     := Foreign Function Interface for Python_ calling C code
cffi_home      := http://cffi.readthedocs.org/

define cffi_desc
Convenient and reliable way of calling C code from Python_.

The aim of this project is to provide a convenient and reliable way of calling C
code from Python_. It keeps Python logic in Python_, and minimises the C
required. It is able to work at either the C API or ABI level, unlike most other
approaches, that only support the ABI level.
endef

define fetch_cffi_dist
$(call download_csum,$(cffi_dist_url),\
                     $(FETCHDIR)/$(cffi_dist_name),\
                     $(cffi_dist_sum))
endef
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
