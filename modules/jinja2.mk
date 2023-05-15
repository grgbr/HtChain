################################################################################
# Jinja2 Python modules
################################################################################

jinja2_dist_url  := https://files.pythonhosted.org/packages/7a/ff/75c28576a1d900e87eb6335b063fab47a8ef3c8b4d88524c4bf78f670cce/Jinja2-3.1.2.tar.gz
jinja2_dist_sum  := 5dfe122c1beef5305b34d25f22f96607bd3a6cba098b03091850ea36fefe62b645a7218d7584b35bea252393ac922c9bb3654a9e90f23bcfb273e811fcf2f2c1
jinja2_dist_name := $(subst J,j,$(notdir $(jinja2_dist_url)))
jinja2_vers      := $(patsubst jinja2-%.tar.gz,%,$(jinja2_dist_name))
jinja2_brief     := Small but fast and easy to use stand-alone template engine
jinja2_home      := https://palletsprojects.com/p/jinja/

define jinja2_desc
Jinja2 is a template engine written in pure Python_. It provides a Django
inspired non-XML syntax but supports inline expressions and an optional
sandboxed environment.

The key-features are:

* Configurable syntax. If you are generating LaTeX or other formats with
  Jinja2 you can change the delimiters to something that integrates better
  into the LaTeX markup.
* Fast. While performance is not the primarily target of Jinja2 it\'s
  surprisingly fast. The overhead compared to regular Python_ code was reduced
  to the very minimum.
* Easy to debug. Jinja2 integrates directly into the Python_ traceback system
  which allows you to debug Jinja2 templates with regular Python_ debugging
  helpers.
* Secure. It\'s possible to evaluate untrusted template code if the optional
  sandbox is enabled. This allows Jinja2 to be used as templating language
  for applications where users may modify the template design.
endef

define fetch_jinja2_dist
$(call download_csum,$(jinja2_dist_url),\
                     $(jinja2_dist_name),\
                     $(jinja2_dist_sum))
endef
$(call gen_fetch_rules,jinja2,jinja2_dist_name,fetch_jinja2_dist)

define xtract_jinja2
$(call rmrf,$(srcdir)/jinja2)
$(call untar,$(srcdir)/jinja2,\
             $(FETCHDIR)/$(jinja2_dist_name),\
             --strip-components=1)
cd $(srcdir)/jinja2 && \
patch -p1 < $(PATCHDIR)/jinja-3.1.2-000-fix_deprecated_test_teardown.patch
endef
$(call gen_xtract_rules,jinja2,xtract_jinja2)

$(call gen_dir_rules,jinja2)

# $(1): targets base name / module name
define jinja2_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stagedir)/bin/pytest --verbose
endef

################################################################################
# Staging definitions
################################################################################

check_stage-jinja2 = $(call jinja2_check_cmds,stage-jinja2)

$(call gen_deps,stage-jinja2,stage-wheel stage-markupsafe)
$(call gen_check_deps,stage-jinja2,stage-jinja2 stage-pytest)
$(call gen_python_module_rules,stage-jinja2,\
                               jinja2,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-jinja2 = $(call jinja2_check_cmds,final-jinja2)

$(call gen_deps,final-jinja2,stage-wheel stage-markupsafe)
$(call gen_check_deps,final-jinja2,stage-jinja2 stage-pytest)
$(call gen_python_module_rules,final-jinja2,\
                               jinja2,\
                               $(PREFIX),\
                               $(finaldir))
