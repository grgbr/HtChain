# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

blinker_dist_url  := https://files.pythonhosted.org/packages/2b/12/82786486cefb68685bb1c151730f510b0f4e5d621d77f245bc0daf9a6c64/blinker-1.5.tar.gz
blinker_dist_sum  := 923e5e2f69c155f2cc42dafbbd70e16e3fde24d2d4aa2ab72fbe386238892462
blinker_dist_name := $(notdir $(blinker_dist_url))

define fetch_blinker_dist
$(call _download,$(blinker_dist_url),\
                 $(FETCHDIR)/$(blinker_dist_name).tmp)
cat $(FETCHDIR)/$(blinker_dist_name).tmp | \
	sha256sum --check --status <(echo "$(blinker_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(blinker_dist_name).tmp,\
          $(FETCHDIR)/$(blinker_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(blinker_dist_name)'
endef

# As fetch_blinker_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(blinker_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,blinker,\
                       blinker_dist_name,\
                       fetch_blinker_dist)

define xtract_blinker
$(call rmrf,$(srcdir)/blinker)
$(call untar,$(srcdir)/blinker,\
             $(FETCHDIR)/$(blinker_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,blinker,xtract_blinker)

$(call gen_dir_rules,blinker)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-blinker,stage-python)

$(call gen_python_module_rules,stage-blinker,blinker,$(stagedir))
