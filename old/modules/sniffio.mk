sniffio_dist_url  := https://files.pythonhosted.org/packages/cd/50/d49c388cae4ec10e8109b1b833fd265511840706808576df3ada99ecb0ac/sniffio-1.3.0.tar.gz
sniffio_dist_sum  := e60305c5e5d314f5389259b7f22aaa33d8f7dee49763119234af3755c55b9101
sniffio_dist_name := $(notdir $(sniffio_dist_url))

define fetch_sniffio_dist
$(call _download,$(sniffio_dist_url),$(FETCHDIR)/$(sniffio_dist_name).tmp)
cat $(FETCHDIR)/$(sniffio_dist_name).tmp | \
	sha256sum --check --status <(echo "$(sniffio_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(sniffio_dist_name).tmp,\
          $(FETCHDIR)/$(sniffio_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(sniffio_dist_name)'
endef

# As fetch_sniffio_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(sniffio_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,sniffio,sniffio_dist_name,fetch_sniffio_dist)

define xtract_sniffio
$(call rmrf,$(srcdir)/sniffio)
$(call untar,$(srcdir)/sniffio,\
             $(FETCHDIR)/$(sniffio_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,sniffio,xtract_sniffio)

$(call gen_dir_rules,sniffio)

# $(1): targets base name / module name
define sniffio_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
    PYTHONPATH="$(builddir)/$(strip $(1))" \
$(stagedir)/bin/pytest
endef

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-sniffio,stage-python)
$(call gen_check_deps,stage-sniffio,stage-pytest stage-curio)

check_stage-sniffio = $(call sniffio_check_cmds,stage-sniffio)
$(call gen_python_module_rules,stage-sniffio,sniffio,\
                                             $(stagedir),\
                                             ,\
                                             check_stage-sniffio)

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-sniffio,stage-python)
$(call gen_check_deps,final-sniffio,stage-pytest stage-curio)

check_final-sniffio = $(call sniffio_check_cmds,final-sniffio)
$(call gen_python_module_rules,final-sniffio,sniffio,\
                                             $(PREFIX),\
                                             $(finaldir),\
                                             check_final-sniffio)
