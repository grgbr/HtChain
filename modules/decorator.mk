# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

decorator_dist_url  := https://files.pythonhosted.org/packages/66/0c/8d907af351aa16b42caae42f9d6aa37b900c67308052d10fdce809f8d952/decorator-5.1.1.tar.gz
decorator_dist_sum  := 637996211036b6385ef91435e4fae22989472f9d571faba8927ba8253acbc330
decorator_dist_name := $(notdir $(decorator_dist_url))

define fetch_decorator_dist
$(call _download,$(decorator_dist_url),$(FETCHDIR)/$(decorator_dist_name).tmp)
cat $(FETCHDIR)/$(decorator_dist_name).tmp | \
	sha256sum --check --status <(echo "$(decorator_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(decorator_dist_name).tmp,\
          $(FETCHDIR)/$(decorator_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(decorator_dist_name)'
endef

# As fetch_decorator_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(decorator_dist_name): SHELL:=/bin/bash
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

$(call gen_deps,stage-decorator,stage-python)

$(call gen_python_module_rules,stage-decorator,decorator,$(stagedir))
