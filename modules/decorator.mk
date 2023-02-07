################################################################################
# decorator modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

decorator_dist_url  := https://files.pythonhosted.org/packages/66/0c/8d907af351aa16b42caae42f9d6aa37b900c67308052d10fdce809f8d952/decorator-5.1.1.tar.gz
decorator_dist_sum  := 584857ffb0c3e52344b473ceb9e28adfd7d789d480a528471f8ab37be055ebe5feb170f41077010e25350e1c311189d45b90773cf12f0043de98ea8ebcde20ab
decorator_dist_name := $(notdir $(decorator_dist_url))
decorator_vers      := $(patsubst decorator-%.tar.gz,%,$(decorator_dist_name))
decorator_brief     := Simplify usage of Python_ decorators by programmers
decorator_home      := https://github.com/micheles/decorator

define decorator_desc
Python_ 2.4 decorators have significantly changed the way Python_ programs are
structured:

* decorators help reduce boilerplate code;
* decorators help the separation of concerns;
* decorators enhance readability and maintainability;
* decorators are very explicit.

Still, as of now, writing custom decorators correctly requires some experience
and is not as easy as it could be. For instance, typical implementations of
decorators involve nested functions and we all know that flat is better than
nested.
The aim of the decorator module is to simplify the usage of decorators for the
average programmer and to popularize decorators usage giving examples of useful
decorators, such as memoize, tracing, redirecting_stdout, locked, etc...
endef

define fetch_decorator_dist
$(call download_csum,$(decorator_dist_url),\
                     $(FETCHDIR)/$(decorator_dist_name),\
                     $(decorator_dist_sum))
endef
$(call gen_fetch_rules,decorator,decorator_dist_name,fetch_decorator_dist)

define xtract_decorator
$(call rmrf,$(srcdir)/decorator)
$(call untar,$(srcdir)/decorator,\
             $(FETCHDIR)/$(decorator_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,decorator,xtract_decorator)

$(call gen_dir_rules,decorator)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-decorator,stage-wheel)

$(call gen_python_module_rules,stage-decorator,decorator,$(stagedir))
