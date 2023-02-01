# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

pytest-xdist_dist_url  := https://files.pythonhosted.org/packages/0d/e5/f7ece02dc1b4bc24a3e37be6a78251e03fff4193126d7ce126c450644696/pytest-xdist-3.1.0.tar.gz
pytest-xdist_dist_sum  := 40fdb8f3544921c5dfcd486ac080ce22870e71d82ced6d2e78fa97c2addd480c
pytest-xdist_dist_name := $(notdir $(pytest-xdist_dist_url))

define fetch_pytest-xdist_dist
$(call _download,$(pytest-xdist_dist_url),\
                 $(FETCHDIR)/$(pytest-xdist_dist_name).tmp)
cat $(FETCHDIR)/$(pytest-xdist_dist_name).tmp | \
	sha256sum --check --status <(echo "$(pytest-xdist_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(pytest-xdist_dist_name).tmp,\
          $(FETCHDIR)/$(pytest-xdist_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(pytest-xdist_dist_name)'
endef

# As fetch_pytest-xdist_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(pytest-xdist_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,pytest-xdist,\
                       pytest-xdist_dist_name,\
                       fetch_pytest-xdist_dist)

define xtract_pytest-xdist
$(call rmrf,$(srcdir)/pytest-xdist)
$(call untar,$(srcdir)/pytest-xdist,\
             $(FETCHDIR)/$(pytest-xdist_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,pytest-xdist,xtract_pytest-xdist)

$(call gen_dir_rules,pytest-xdist)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-pytest-xdist,stage-pytest stage-execnet)

$(call gen_python_module_rules,stage-pytest-xdist,\
                               pytest-xdist,\
                               $(stagedir),\
                               ,\
                               check_stage-pytest-xdist)
