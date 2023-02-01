# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

brotlipy_dist_url  := https://files.pythonhosted.org/packages/d9/91/bc79b88590e4f662bd40a55a2b6beb0f15da4726732efec5aa5a3763d856/brotlipy-0.7.0.tar.gz
brotlipy_dist_sum  := 36def0b859beaf21910157b4c33eb3b06d8ce459c942102f16988cca6ea164df
brotlipy_dist_name := $(notdir $(brotlipy_dist_url))

define fetch_brotlipy_dist
$(call _download,$(brotlipy_dist_url),$(FETCHDIR)/$(brotlipy_dist_name).tmp)
cat $(FETCHDIR)/$(brotlipy_dist_name).tmp | \
	sha256sum --check --status <(echo "$(brotlipy_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(brotlipy_dist_name).tmp,\
          $(FETCHDIR)/$(brotlipy_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(brotlipy_dist_name)'
endef

# As fetch_brotlipy_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(brotlipy_dist_name): SHELL:=/bin/bash
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
