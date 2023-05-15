################################################################################
# tornado Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

tornado_dist_url  := https://files.pythonhosted.org/packages/f3/9e/225a41452f2d9418d89be5e32cf824c84fe1e639d350d6e8d49db5b7f73a/tornado-6.2.tar.gz
tornado_dist_sum  := 157cbeee21bef29ac68b319329e7fc57db4c68dbb5a245e2171b7a28427ebbfe16b745e3bdbdec5912caae5eaa60c3cbbf8830c9c76fec5ffdf025e234468517
tornado_dist_name := $(notdir $(tornado_dist_url))
tornado_vers      := $(patsubst tornado-%.tar.gz,%,$(tornado_dist_name))
tornado_brief     := Scalable, non-blocking web server and tools for Python_
tornado_home      := http://www.tornadoweb.org/

define tornado_desc
Tornado is a Python_ web framework and asynchronous networking library,
originally developed at FriendFeed. By using non-blocking network I/O, Tornado
can scale to tens of thousands of open connections, making it ideal for long
polling, WebSockets, and other applications that require a long-lived connection
to each user.
endef

define fetch_tornado_dist
$(call download_csum,$(tornado_dist_url),\
                     $(tornado_dist_name),\
                     $(tornado_dist_sum))
endef
$(call gen_fetch_rules,tornado,tornado_dist_name,fetch_tornado_dist)

define xtract_tornado
$(call rmrf,$(srcdir)/tornado)
$(call untar,$(srcdir)/tornado,\
             $(FETCHDIR)/$(tornado_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,tornado,xtract_tornado)

$(call gen_dir_rules,tornado)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-tornado,stage-wheel)

$(call gen_python_module_rules,stage-tornado,tornado,$(stagedir))
