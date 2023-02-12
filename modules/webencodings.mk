################################################################################
# webencodings Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

webencodings_dist_url  := https://files.pythonhosted.org/packages/0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47/webencodings-0.5.1.tar.gz
webencodings_dist_sum  := b727b01bac6ec79bca517960d27b4c0668b295f25559471b9641c2c33dab55db6dac9c990952177964c6418382c22831b14d57df5e632d51d7abf97b61f24326
webencodings_dist_name := $(notdir $(webencodings_dist_url))
webencodings_vers      := $(patsubst webencodings-%.tar.gz,%,$(webencodings_dist_name))
webencodings_brief     := Python_ implementation of the WHATWG Encoding standard
webencodings_home      := https://github.com/SimonSapin/python-webencodings

define webencodings_desc
In order to be compatible with legacy web content when interpreting something
like Content-Type: text/html; charset=latin1, tools need to use a particular set
of aliases for encoding labels as well as some overriding rules. For example,
US-ASCII and iso-8859-1 on the web are actually aliases for windows-1252, and an
UTF-8 or UTF-16 BOM takes precedence over any other encoding declaration.  The
Encoding standard defines all such details so that implementations do not have
to reverse-engineer each other.

This module has encoding labels and BOM detection, but the actual implementation
for encoders and decoders is Python_\'s.
endef

define fetch_webencodings_dist
$(call download_csum,$(webencodings_dist_url),\
                     $(FETCHDIR)/$(webencodings_dist_name),\
                     $(webencodings_dist_sum))
endef
$(call gen_fetch_rules,webencodings,webencodings_dist_name,fetch_webencodings_dist)

define xtract_webencodings
$(call rmrf,$(srcdir)/webencodings)
$(call untar,$(srcdir)/webencodings,\
             $(FETCHDIR)/$(webencodings_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,webencodings,xtract_webencodings)

$(call gen_dir_rules,webencodings)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-webencodings,stage-wheel)

$(call gen_python_module_rules,stage-webencodings,webencodings,$(stagedir))
