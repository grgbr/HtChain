coverage_enable_subprocess_dist_url  := https://files.pythonhosted.org/packages/31/f4/57693bcf041ba641501b7a2fafc9d3d2de647355d78c6a2e07fb53648eaa/coverage_enable_subprocess-1.0.tar.gz
coverage_enable_subprocess_dist_sum  := fdbd3dc9532007cd87ef84f38e16024c5b0ccb4ab2d1755225a7edf937acc011
coverage_enable_subprocess_dist_name := $(notdir $(coverage_enable_subprocess_dist_url))

define fetch_coverage_enable_subprocess_dist
$(call _download,$(coverage_enable_subprocess_dist_url),\
                 $(FETCHDIR)/$(coverage_enable_subprocess_dist_name).tmp)
cat $(FETCHDIR)/$(coverage_enable_subprocess_dist_name).tmp | \
	sha256sum --check \
	          --status \
	          <(echo "$(coverage_enable_subprocess_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(coverage_enable_subprocess_dist_name).tmp,\
          $(FETCHDIR)/$(coverage_enable_subprocess_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(coverage_enable_subprocess_dist_name)'
endef

# As fetch_coverage_enable_subprocess_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(coverage_enable_subprocess_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,coverage_enable_subprocess,\
       coverage_enable_subprocess_dist_name,\
       fetch_coverage_enable_subprocess_dist)

define xtract_coverage_enable_subprocess
$(call rmrf,$(srcdir)/coverage_enable_subprocess)
$(call untar,$(srcdir)/coverage_enable_subprocess,\
             $(FETCHDIR)/$(coverage_enable_subprocess_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,coverage_enable_subprocess,\
                        xtract_coverage_enable_subprocess)

$(call gen_dir_rules,coverage_enable_subprocess)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-coverage_enable_subprocess,stage-coverage)

check_stage-coverage_enable_subprocess = \
	$(call coverage_enable_subprocess_check_cmds,\
	       stage-coverage_enable_subprocess)
$(call gen_python_module_rules,stage-coverage_enable_subprocess,\
                               coverage_enable_subprocess,\
                               $(stagedir),\
                               ,\
                               check_stage-coverage_enable_subprocess)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-coverage_enable_subprocess,stage-coverage)

check_final-coverage_enable_subprocess = \
	$(call coverage_enable_subprocess_check_cmds,\
	       final-coverage_enable_subprocess)
$(call gen_python_module_rules,final-coverage_enable_subprocess,\
                               coverage_enable_subprocess,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-coverage_enable_subprocess)
