################################################################################
# pycparser Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pycparser_dist_url  := https://files.pythonhosted.org/packages/5e/0b/95d387f5f4433cb0f53ff7ad859bd2c6051051cebbb564f139a999ab46de/pycparser-2.21.tar.gz
pycparser_dist_sum  := e61fbdde484d1cf74d4b27bdde40cf2da4b7028ca8ecd37c83d77473dab707d457321aecaf97da3b114c1d58a4eb200290b76f9c958044b57e5fed949895b5f0
pycparser_dist_name := $(notdir $(pycparser_dist_url))
pycparser_vers      := $(patsubst pycparser-%.tar.gz,%,$(pycparser_dist_name))
pycparser_brief     := C parser in Python_
pycparser_home      := https://github.com/eliben/pycparser

define pycparser_desc
pycparser is a complete parser of the C language, written in pure Python_ using
the PLY parsing library. It parses C code into an AST and can serve as a
front-end for C compilers or analysis tools.
endef

define fetch_pycparser_dist
$(call download_csum,$(pycparser_dist_url),\
                     $(pycparser_dist_name),\
                     $(pycparser_dist_sum))
endef
$(call gen_fetch_rules,pycparser,pycparser_dist_name,fetch_pycparser_dist)

define xtract_pycparser
$(call rmrf,$(srcdir)/pycparser)
$(call untar,$(srcdir)/pycparser,\
             $(FETCHDIR)/$(pycparser_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pycparser,xtract_pycparser)

$(call gen_dir_rules,pycparser)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pycparser,stage-wheel)

$(call gen_python_module_rules,stage-pycparser,pycparser,$(stagedir))
