# This is a backport of the BaseExceptionGroup and ExceptionGroup classes from
# Python 3.11.
# NO MORE NEEDED IN PYTHON 3.11 !
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

exceptiongroup_dist_url  := https://files.pythonhosted.org/packages/15/ab/dd27fb742b19a9d020338deb9ab9a28796524081bca880ac33c172c9a8f6/exceptiongroup-1.1.0.tar.gz
exceptiongroup_dist_sum  := bcb67d800a4497e1b404c2dd44fca47d3b7a5e5433dbab67f96c1a685cdfdf23
exceptiongroup_dist_name := $(notdir $(exceptiongroup_dist_url))

define fetch_exceptiongroup_dist
$(call _download,$(exceptiongroup_dist_url),$(FETCHDIR)/$(exceptiongroup_dist_name).tmp)
cat $(FETCHDIR)/$(exceptiongroup_dist_name).tmp | \
	sha256sum --check --status <(echo "$(exceptiongroup_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(exceptiongroup_dist_name).tmp,\
          $(FETCHDIR)/$(exceptiongroup_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(exceptiongroup_dist_name)'
endef

# As fetch_exceptiongroup_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(exceptiongroup_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,exceptiongroup,exceptiongroup_dist_name,fetch_exceptiongroup_dist)

define xtract_exceptiongroup
$(call rmrf,$(srcdir)/exceptiongroup)
$(call untar,$(srcdir)/exceptiongroup,\
             $(FETCHDIR)/$(exceptiongroup_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,exceptiongroup,xtract_exceptiongroup)

$(call gen_dir_rules,exceptiongroup)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-exceptiongroup,stage-flit-scm)

$(call gen_python_module_rules,stage-exceptiongroup,exceptiongroup,$(stagedir))
