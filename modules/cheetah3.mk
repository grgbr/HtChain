cheetah3_dist_url  := https://files.pythonhosted.org/packages/23/33/ace0250068afca106c1df34348ab0728e575dc9c61928d216de3e381c460/Cheetah3-3.2.6.post1.tar.gz
cheetah3_dist_sum  := 58b5d84e5fbff6cf8e117414b3ea49ef51654c02ee887d155113c5b91d761967
cheetah3_dist_name := $(notdir $(cheetah3_dist_url))

define fetch_cheetah3_dist
$(call _download,$(cheetah3_dist_url),$(FETCHDIR)/$(cheetah3_dist_name).tmp)
cat $(FETCHDIR)/$(cheetah3_dist_name).tmp | \
	sha256sum --check --status <(echo "$(cheetah3_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(cheetah3_dist_name).tmp,\
          $(FETCHDIR)/$(cheetah3_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(cheetah3_dist_name)'
endef

# As fetch_cheetah3_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(cheetah3_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,cheetah3,cheetah3_dist_name,fetch_cheetah3_dist)

define xtract_cheetah3
$(call rmrf,$(srcdir)/cheetah3)
$(call untar,$(srcdir)/cheetah3,\
             $(FETCHDIR)/$(cheetah3_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cheetah3,xtract_cheetah3)

$(call gen_dir_rules,cheetah3)

# $(1): targets base name / module name
define cheetah3_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stage_python) Cheetah/Tests/Test.py
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cheetah3,stage-markdown stage-pygments)
$(call gen_check_deps,stage-cheetah3,stage-cheetah3)

check_stage-cheetah3 = $(call cheetah3_check_cmds,stage-cheetah3)
$(call gen_python_module_rules,stage-cheetah3,\
                               cheetah3,\
                               $(stagedir),\
                               ,\
                               check_stage-cheetah3)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-cheetah3,stage-markdown stage-pygments)
$(call gen_check_deps,final-cheetah3,stage-cheetah3)

check_final-cheetah3 = $(call cheetah3_check_cmds,final-cheetah3)
$(call gen_python_module_rules,final-cheetah3,\
                               cheetah3,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-cheetah3)
