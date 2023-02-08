################################################################################
# mock Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

mock_dist_url  := https://files.pythonhosted.org/packages/a9/c8/7f5fc5ee6a666d7e4ee7a3222bcb37ebebaea3697d7bf54517728f56bb28/mock-5.0.1.tar.gz
mock_dist_sum  := 1c63736e2e1573e1ab2041edbb200c3d18cc18403117491c9a5cb663245616a942fa16ac1a4974fa91b88d02f8bcde2f50833fc7ddbae5ded018fcbe6d3befb4
mock_dist_name := $(notdir $(mock_dist_url))
mock_vers      := $(patsubst mock-%.tar.gz,%,$(mock_dist_name))
mock_brief     := Python_ mocking and Testing Library
mock_home      := http://mock.readthedocs.org/

define mock_desc
mock provides a core ``mock.Mock`` class that is intended to reduce the need to
create a host of trivial stubs throughout your test suite.  After performing an
action, you can make assertions about which methods / attributes were used and
arguments they were called with. You can also specify return values and set
specific attributes in the normal way.
endef

define fetch_mock_dist
$(call download_csum,$(mock_dist_url),\
                     $(FETCHDIR)/$(mock_dist_name),\
                     $(mock_dist_sum))
endef
$(call gen_fetch_rules,mock,mock_dist_name,fetch_mock_dist)

define xtract_mock
$(call rmrf,$(srcdir)/mock)
$(call untar,$(srcdir)/mock,\
             $(FETCHDIR)/$(mock_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,mock,xtract_mock)

$(call gen_dir_rules,mock)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-mock,stage-wheel)

$(call gen_python_module_rules,stage-mock,mock,$(stagedir))
