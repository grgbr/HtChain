################################################################################
# cython modules
################################################################################

cython_dist_url  := https://files.pythonhosted.org/packages/dc/f6/e8e302f9942cbebede88b1a0c33d0be3a738c3ac37abae87254d58ffc51c/Cython-0.29.33.tar.gz
cython_dist_sum  := 09be78a5d85756045b1216f8113c66935e203a0000bba3e3167aebf341e11b5644232891bd7f66c907f5e97286d319cf60fff413213dcf4c3ea96bf3acf0a121
cython_dist_name := $(subst C,c,$(notdir $(cython_dist_url)))
cython_vers      := $(patsubst cython-%.tar.gz,%,$(cython_dist_name))
cython_brief     := C-Extensions for Python_
cython_home      := https://cython.org/

define cython_desc
Cython is a language that makes writing C extensions for the Python_ language as
easy as Python_ itself. Cython is based on the well-known Pyrex, but supports
more cutting edge functionality and optimizations.

The Cython language is very close to the Python_ language, but Cython
additionally supports calling C functions and declaring C types on variables and
class attributes. This allows the compiler to generate very efficient C code
from Cython code.

This makes Cython the ideal language for wrapping external C libraries, and for
fast C modules that speed up the execution of Python_ code.
endef

define fetch_cython_dist
$(call download_csum,$(cython_dist_url),\
                     $(FETCHDIR)/$(cython_dist_name),\
                     $(cython_dist_sum))
endef
$(call gen_fetch_rules,cython,cython_dist_name,fetch_cython_dist)

define xtract_cython
$(call rmrf,$(srcdir)/cython)
$(call untar,$(srcdir)/cython,\
             $(FETCHDIR)/$(cython_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cython,xtract_cython)

$(call gen_dir_rules,cython)

# $(1): targets base name / module name
define cython_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) runtests.py -v
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-cython,stage-python)

check_stage-cython = $(call cython_check_cmds,stage-cython)
$(call gen_python_module_rules,stage-cython,\
                               cython,\
                               $(stagedir), \
                               ,\
                               check_stage-cython)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-cython,stage-python)

check_final-cython = $(call cython_check_cmds,final-cython)
$(call gen_python_module_rules,final-cython,\
                               cython,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-cython)
