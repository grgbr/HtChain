################################################################################
# charset-normalizer modules
################################################################################

charset-normalizer_dist_url  := https://files.pythonhosted.org/packages/96/d7/1675d9089a1f4677df5eb29c3f8b064aa1e70c1251a0a8a127803158942d/charset-normalizer-3.0.1.tar.gz
charset-normalizer_dist_sum  := 25bfb8d708f2c1827d4f074f1b3c4f9932f7a00b833423f9edd6d5a942af39eeb703dea7471bdf2764094e8d01af7d98017c030f7b7a2a1a24e65c1161aef52f
charset-normalizer_dist_name := $(notdir $(charset-normalizer_dist_url))
charset-normalizer_vers      := $(strip \
                                  $(patsubst charset-normalizer-%.tar.gz,\
                                             %,\
                                             $(charset-normalizer_dist_name)))
charset-normalizer_brief     := Python_ charset, encoding and language detection
charset-normalizer_home      := https://github.com/Ousret/charset_normalizer

define charset-normalizer_desc
charset-normalizer is a library for detection of charsets, encodings, and
languages in Python_ programs. It can be compared to chardet, with a different
approach, which intends to make it faster and more reliable.  charset-normalizer
can also detect natural languages.

All `IANA <https://www.iana.org/>`_ character set names for which the Python_
core library provides codecs are supported.
endef

define fetch_charset-normalizer_dist
$(call download_csum,$(charset-normalizer_dist_url),\
                     $(FETCHDIR)/$(charset-normalizer_dist_name),\
                     $(charset-normalizer_dist_sum))
endef
$(call gen_fetch_rules,charset-normalizer,\
                       charset-normalizer_dist_name,\
                       fetch_charset-normalizer_dist)

define xtract_charset-normalizer
$(call rmrf,$(srcdir)/charset-normalizer)
$(call untar,$(srcdir)/charset-normalizer,\
             $(FETCHDIR)/$(charset-normalizer_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,charset-normalizer,xtract_charset-normalizer)

$(call gen_dir_rules,charset-normalizer)

# $(1): targets base name / module name
define charset-normalizer_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-charset-normalizer,stage-python)
$(call gen_check_deps,stage-charset-normalizer,stage-pytest-cov)

check_stage-charset-normalizer = $(call charset-normalizer_check_cmds,\
                                        stage-charset-normalizer)
$(call gen_python_module_rules,stage-charset-normalizer,\
                               charset-normalizer,\
                               $(stagedir),\
                               ,\
                               check_stage-charset-normalizer)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-charset-normalizer,stage-python)
$(call gen_check_deps,final-charset-normalizer,stage-pytest-cov)

check_final-charset-normalizer = $(call charset-normalizer_check_cmds,\
                                        final-charset-normalizer)
$(call gen_python_module_rules,final-charset-normalizer,\
                               charset-normalizer,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-charset-normalizer)
