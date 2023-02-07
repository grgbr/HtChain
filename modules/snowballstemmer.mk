snowballstemmer_dist_url  := https://files.pythonhosted.org/packages/44/7b/af302bebf22c749c56c9c3e8ae13190b5b5db37a33d9068652e8f73b7089/snowballstemmer-2.2.0.tar.gz
snowballstemmer_dist_sum  := 09b16deb8547d3412ad7b590689584cd0fe25ec8db3be37788be3810cbf19cb1
snowballstemmer_dist_name := $(notdir $(snowballstemmer_dist_url))

define fetch_snowballstemmer_dist
$(call _download,$(snowballstemmer_dist_url),$(FETCHDIR)/$(snowballstemmer_dist_name).tmp)
cat $(FETCHDIR)/$(snowballstemmer_dist_name).tmp | \
	sha256sum --check --status <(echo "$(snowballstemmer_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(snowballstemmer_dist_name).tmp,\
          $(FETCHDIR)/$(snowballstemmer_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(snowballstemmer_dist_name)'
endef

# As fetch_snowballstemmer_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(snowballstemmer_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,snowballstemmer,\
                       snowballstemmer_dist_name,\
                       fetch_snowballstemmer_dist)

define xtract_snowballstemmer
$(call rmrf,$(srcdir)/snowballstemmer)
$(call untar,$(srcdir)/snowballstemmer,\
             $(FETCHDIR)/$(snowballstemmer_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,snowballstemmer,xtract_snowballstemmer)

$(call gen_dir_rules,snowballstemmer)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-snowballstemmer,stage-wheel)

$(call gen_python_module_rules,stage-snowballstemmer,\
                               snowballstemmer,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-snowballstemmer,stage-wheel)

$(call gen_python_module_rules,final-snowballstemmer,\
                               snowballstemmer,\
                               $(PREFIX),\
                               $(finaldir))
