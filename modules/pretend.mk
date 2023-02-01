# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pretend_dist_url  := https://files.pythonhosted.org/packages/3c/f8/7c86fd40c9e83deb10891a60d2dcb1af0b3b38064d72ebdb12486acc824f/pretend-1.0.9.tar.gz
pretend_dist_sum  := c90eb810cde8ebb06dafcb8796f9a95228ce796531bc806e794c2f4649aa1b10
pretend_dist_name := $(notdir $(pretend_dist_url))

define fetch_pretend_dist
$(call _download,$(pretend_dist_url),\
                 $(FETCHDIR)/$(pretend_dist_name).tmp)
cat $(FETCHDIR)/$(pretend_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pretend_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pretend_dist_name).tmp,\
          $(FETCHDIR)/$(pretend_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pretend_dist_name)'
endef

# As fetch_pretend_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pretend_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pretend,\
                       pretend_dist_name,\
                       fetch_pretend_dist)

define xtract_pretend
$(call rmrf,$(srcdir)/pretend)
$(call untar,$(srcdir)/pretend,\
             $(FETCHDIR)/$(pretend_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pretend,xtract_pretend)

$(call gen_dir_rules,pretend)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pretend,stage-python)

$(call gen_python_module_rules,stage-pretend,pretend,$(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-pretend,stage-python)

$(call gen_python_module_rules,final-pretend,pretend,$(PREFIX),$(finaldir))
