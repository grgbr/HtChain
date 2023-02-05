################################################################################
# exceptiongroup Python modules
#
# This is a backport of the BaseExceptionGroup and ExceptionGroup classes from
# Python 3.11.
# NO MORE NEEDED IN PYTHON 3.11 !
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

exceptiongroup_dist_url  := https://files.pythonhosted.org/packages/15/ab/dd27fb742b19a9d020338deb9ab9a28796524081bca880ac33c172c9a8f6/exceptiongroup-1.1.0.tar.gz
exceptiongroup_dist_sum  := 99e3745ed04727bb1d1099dcc1da64e59ae14bb45911334268c8469d04fec88bfecbf1a57732d789a93f4c5e9ae6d472b6f3663ea1bd8bbee660f5521605a9d4
exceptiongroup_dist_name := $(notdir $(exceptiongroup_dist_url))
exceptiongroup_vers      := $(patsubst exceptiongroup-%.tar.gz,%,$(exceptiongroup_dist_name))
exceptiongroup_brief     := Backport of Python_ PEP 654 (exception groups)
exceptiongroup_home      := https://github.com/agronholm/exceptiongroup/

define exceptiongroup_desc
This is a backport of the ``BaseExceptionGroup`` and ``ExceptionGroup`` classes
from Python_ 3.11.
endef

define fetch_exceptiongroup_dist
$(call download_csum,$(exceptiongroup_dist_url),\
                     $(FETCHDIR)/$(exceptiongroup_dist_name),\
                     $(exceptiongroup_dist_sum))
endef
$(call gen_fetch_rules,exceptiongroup,\
                       exceptiongroup_dist_name,\
                       fetch_exceptiongroup_dist)

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
