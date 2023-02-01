imagesize_dist_url  := https://files.pythonhosted.org/packages/a7/84/62473fb57d61e31fef6e36d64a179c8781605429fd927b5dd608c997be31/imagesize-1.4.1.tar.gz
imagesize_dist_sum  := 69150444affb9cb0d5cc5a92b3676f0b2fb7cd9ae39e947a5e11a36b4497cd4a
imagesize_dist_name := $(notdir $(imagesize_dist_url))

define fetch_imagesize_dist
$(call _download,$(imagesize_dist_url),$(FETCHDIR)/$(imagesize_dist_name).tmp)
cat $(FETCHDIR)/$(imagesize_dist_name).tmp | \
	sha256sum --check --status <(echo "$(imagesize_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(imagesize_dist_name).tmp,\
          $(FETCHDIR)/$(imagesize_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(imagesize_dist_name)'
endef

# As fetch_imagesize_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(imagesize_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,imagesize,imagesize_dist_name,fetch_imagesize_dist)

define xtract_imagesize
$(call rmrf,$(srcdir)/imagesize)
$(call untar,$(srcdir)/imagesize,\
             $(FETCHDIR)/$(imagesize_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,imagesize,xtract_imagesize)

$(call gen_dir_rules,imagesize)

# $(1): targets base name / module name
define imagesize_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stage_python) -m unittest discover --verbose
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-imagesize,stage-python)

check_stage-imagesize = $(call imagesize_check_cmds,stage-imagesize)
$(call gen_python_module_rules,stage-imagesize,\
                               imagesize,\
                               $(stagedir),\
                               ,\
                               check_stage-imagesize)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-imagesize,stage-python)

check_final-imagesize = $(call imagesize_check_cmds,final-imagesize)
$(call gen_python_module_rules,final-imagesize,\
                               imagesize,\
                               $(PREFIX),\
                               $(finaldir),\
                               check_final-imagesize)
