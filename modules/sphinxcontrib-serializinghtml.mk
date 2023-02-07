sphinxcontrib-serializinghtml_dist_url  := https://files.pythonhosted.org/packages/b5/72/835d6fadb9e5d02304cf39b18f93d227cd93abd3c41ebf58e6853eeb1455/sphinxcontrib-serializinghtml-1.1.5.tar.gz
sphinxcontrib-serializinghtml_dist_sum  := aa5f6de5dfdf809ef505c4895e51ef5c9eac17d0f287933eb49ec495280b6952
sphinxcontrib-serializinghtml_dist_name := $(notdir $(sphinxcontrib-serializinghtml_dist_url))

define fetch_sphinxcontrib-serializinghtml_dist
$(call _download,$(sphinxcontrib-serializinghtml_dist_url),\
                 $(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name).tmp)
cat $(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(sphinxcontrib-serializinghtml_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name).tmp,\
          $(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name)'
endef

# As fetch_sphinxcontrib-serializinghtml_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,sphinxcontrib-serializinghtml,\
                       sphinxcontrib-serializinghtml_dist_name,\
                       fetch_sphinxcontrib-serializinghtml_dist)

define xtract_sphinxcontrib-serializinghtml
$(call rmrf,$(srcdir)/sphinxcontrib-serializinghtml)
$(call untar,$(srcdir)/sphinxcontrib-serializinghtml,\
             $(FETCHDIR)/$(sphinxcontrib-serializinghtml_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sphinxcontrib-serializinghtml,\
                        xtract_sphinxcontrib-serializinghtml)

$(call gen_dir_rules,sphinxcontrib-serializinghtml)

# $(1): targets base name / module name
define sphinxcontrib-serializinghtml_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sphinxcontrib-serializinghtml,stage-wheel)
$(call gen_check_deps,stage-sphinxcontrib-serializinghtml,\
                      stage-pytest stage-sphinx)

check_stage-sphinxcontrib-serializinghtml = \
	$(call sphinxcontrib-serializinghtml_check_cmds,\
	       stage-sphinxcontrib-serializinghtml)
$(call gen_python_module_rules,stage-sphinxcontrib-serializinghtml,\
                               sphinxcontrib-serializinghtml,\
                               $(stagedir),\
                               ,\
                               check_stage-sphinxcontrib-serializinghtml)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sphinxcontrib-serializinghtml,stage-wheel)
$(call gen_check_deps,final-sphinxcontrib-serializinghtml,\
                      stage-pytest stage-sphinx)

check_final-sphinxcontrib-serializinghtml = \
	$(call sphinxcontrib-serializinghtml_check_cmds,\
	       final-sphinxcontrib-serializinghtml)
$(call gen_python_module_rules,final-sphinxcontrib-serializinghtml,\
                               sphinxcontrib-serializinghtml,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-sphinxcontrib-serializinghtml)
