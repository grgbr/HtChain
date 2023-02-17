################################################################################
# idna Python modules
################################################################################

idna_dist_url  := https://files.pythonhosted.org/packages/8b/e1/43beb3d38dba6cb420cefa297822eac205a277ab43e5ba5d5c46faf96438/idna-3.4.tar.gz
idna_dist_sum  := 4060a9304c9bac04efdd0b97ec8f5aeb7e17417e767bf51c5dfc26605edad25ab67456cf6f6a3c5a9f32b8247e46f6343edfd8a6ffbcd6d1075c71e66d089d6a
idna_dist_name := $(notdir $(idna_dist_url))
idna_vers      := $(patsubst idna-%.tar.gz,%,$(idna_dist_name))
idna_brief     := Python_ IDNA2008 (RFC 5891) handling
idna_home      := https://github.com/kjd/idna

define idna_desc
A library to support the Internationalised Domain Names in Applications (IDNA)
protocol as specified in RFC 5891. This version of the protocol is often
referred to as “IDNA2008” and can produce different results from the earlier
standard from 2003.

The library is also intended to act as a suitable drop-in replacement for the
“encodings.idna” module that comes with the Python_ standard library but
currently only supports the older 2003 specification.
endef

define fetch_idna_dist
$(call download_csum,$(idna_dist_url),\
                     $(FETCHDIR)/$(idna_dist_name),\
                     $(idna_dist_sum))
endef
$(call gen_fetch_rules,idna,idna_dist_name,fetch_idna_dist)

define xtract_idna
$(call rmrf,$(srcdir)/idna)
$(call untar,$(srcdir)/idna,\
             $(FETCHDIR)/$(idna_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,idna,xtract_idna)

$(call gen_dir_rules,idna)

# $(1): targets base name / module name
define idna_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-idna = $(call idna_check_cmds,stage-idna)

$(call gen_deps,stage-idna,stage-flit_core)
$(call gen_check_deps,stage-idna,stage-pytest)
$(call gen_python_module_rules,stage-idna,idna,$(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-idna = $(call idna_check_cmds,final-idna)

$(call gen_deps,final-idna,stage-flit_core)
$(call gen_check_deps,final-idna,stage-pytest)
$(call gen_python_module_rules,final-idna,\
                               idna,\
                               $(PREFIX),\
                               $(finaldir))
