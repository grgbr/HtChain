################################################################################
# html5lib Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

html5lib_dist_url  := https://files.pythonhosted.org/packages/ac/b6/b55c3f49042f1df3dcd422b7f224f939892ee94f22abcf503a9b7339eaf2/html5lib-1.1.tar.gz
html5lib_dist_sum  := af7c29591007fded99be6c38e3d0ae5a4ac32d71d26046a615918ae732cb1c1ecbf754f47ceca1a53726c3843f3ecea7af87a7362281b45ff3af495815818626
html5lib_dist_name := $(notdir $(html5lib_dist_url))
html5lib_vers      := $(patsubst html5lib-%.tar.gz,%,$(html5lib_dist_name))
html5lib_brief     := HTML parser/tokenizer based on the WHATWG HTML5 specification
html5lib_home      := https://github.com/html5lib/html5lib-python

define html5lib_desc
html5lib is a pure Python_ library for parsing HTML. It is designed to conform
to the HTML 5 specification, which has formalized the error handling algorithms
of popular web browsers.
endef

define fetch_html5lib_dist
$(call download_csum,$(html5lib_dist_url),\
                     $(FETCHDIR)/$(html5lib_dist_name),\
                     $(html5lib_dist_sum))
endef
$(call gen_fetch_rules,html5lib,html5lib_dist_name,fetch_html5lib_dist)

define xtract_html5lib
$(call rmrf,$(srcdir)/html5lib)
$(call untar,$(srcdir)/html5lib,\
             $(FETCHDIR)/$(html5lib_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,html5lib,xtract_html5lib)

$(call gen_dir_rules,html5lib)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-html5lib,stage-six stage-webencodings)

$(call gen_python_module_rules,stage-html5lib,html5lib,$(stagedir))
