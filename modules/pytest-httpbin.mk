################################################################################
# pytest-httpbin Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

pytest-httpbin_dist_url  := https://files.pythonhosted.org/packages/c3/18/4638bf234d6f1e3e540cd0b9c117f0df1b75ef2700af03da2d3c3009026c/pytest-httpbin-1.0.2.tar.gz
pytest-httpbin_dist_sum  := d1982830766916b9aeae0e931862c7dc603fb98a89ff6e7e2735dfe25c81b6353af8a834dec13989312c53efe6fd829ea038eae84552099b86505289033f4efb
pytest-httpbin_dist_name := $(notdir $(pytest-httpbin_dist_url))
pytest-httpbin_vers      := $(patsubst pytest-httpbin-%.tar.gz,%,$(pytest-httpbin_dist_name))
pytest-httpbin_brief     := Pytest_ plugin providing a local httpbin
pytest-httpbin_home      := https://github.com/kevin1024/pytest-httpbin

define pytest-httpbin_desc
httpbin is a WSGI based test server for testing HTTP applications.
pytest-httpbin creates a fixture for the ``py.test`` framework that is
dependency-injected into tests, it automatically starts up a local running
instance of httpbin in a separate thread and provides the test with the URL in
the fixture.
endef

define fetch_pytest-httpbin_dist
$(call download_csum,$(pytest-httpbin_dist_url),\
                     $(pytest-httpbin_dist_name),\
                     $(pytest-httpbin_dist_sum))
endef
$(call gen_fetch_rules,pytest-httpbin,\
                       pytest-httpbin_dist_name,\
                       fetch_pytest-httpbin_dist)

define xtract_pytest-httpbin
$(call rmrf,$(srcdir)/pytest-httpbin)
$(call untar,$(srcdir)/pytest-httpbin,\
             $(FETCHDIR)/$(pytest-httpbin_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-httpbin,xtract_pytest-httpbin)

$(call gen_dir_rules,pytest-httpbin)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-httpbin,stage-pytest stage-httpbin)

$(call gen_python_module_rules,stage-pytest-httpbin,\
                               pytest-httpbin,\
                               $(stagedir))
