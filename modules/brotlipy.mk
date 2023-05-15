################################################################################
# brotlipy modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

brotlipy_dist_url  := https://files.pythonhosted.org/packages/d9/91/bc79b88590e4f662bd40a55a2b6beb0f15da4726732efec5aa5a3763d856/brotlipy-0.7.0.tar.gz
brotlipy_dist_sum  := 2a01e5b2d217043f13316afc4f54569c5dff76d31c296d4be563a5851195380ab80a33a3035ca95effdebffb45806fb9a431a181bba6f9af205b7f5576937268
brotlipy_dist_name := $(notdir $(brotlipy_dist_url))
brotlipy_vers      := $(patsubst brotlipy-%.tar.gz,%,$(brotlipy_dist_name))
brotlipy_brief     := Python_ bindings for the reference Brotli encoder/decoder
brotlipy_home      := https://github.com/python-hyper/brotlipy/

define brotlipy_desc
Brotlipy is a collection of CFFI_ based Python_ bindings to the Brotli
compression reference implementation as written by Google. This enables Python_
software to easily and quickly work with the Brotli compression algorithm,
regardless of what interpreter is being used.
endef

define fetch_brotlipy_dist
$(call download_csum,$(brotlipy_dist_url),\
                     $(brotlipy_dist_name),\
                     $(brotlipy_dist_sum))
endef
$(call gen_fetch_rules,brotlipy,brotlipy_dist_name,fetch_brotlipy_dist)

define xtract_brotlipy
$(call rmrf,$(srcdir)/brotlipy)
$(call untar,$(srcdir)/brotlipy,\
             $(FETCHDIR)/$(brotlipy_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,brotlipy,xtract_brotlipy)

$(call gen_dir_rules,brotlipy)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-brotlipy,stage-cffi)
$(call gen_python_module_rules,stage-brotlipy,brotlipy,$(stagedir))
