ephemeral-port-reserve_dist_url  := https://files.pythonhosted.org/packages/ef/93/3f0b75f75f94227f67ccfe86f989415e40ac054dd67b55dfac7abdc0a2d2/ephemeral_port_reserve-1.1.4.tar.gz
ephemeral-port-reserve_dist_sum  := b8f7da2c97090cb0801949dec1d6d40c97220505b742a70935ffbd43234c14b2
ephemeral-port-reserve_dist_name := $(notdir $(ephemeral-port-reserve_dist_url))

define fetch_ephemeral-port-reserve_dist
$(call _download,$(ephemeral-port-reserve_dist_url),\
                 $(FETCHDIR)/$(ephemeral-port-reserve_dist_name).tmp)
cat $(FETCHDIR)/$(ephemeral-port-reserve_dist_name).tmp | \
	sha256sum --check --status <(echo "$(ephemeral-port-reserve_dist_sum)  -")
$(call mv,$(FETCHDIR)/$(ephemeral-port-reserve_dist_name).tmp,\
          $(FETCHDIR)/$(ephemeral-port-reserve_dist_name))
$(SYNC) --file-system '$(FETCHDIR)/$(ephemeral-port-reserve_dist_name)'
endef

# As fetch_ephemeral-port-reserve_dist() macro above relies upon a complex process
# substitution construct, enforce usage of bash a shell.
$(FETCHDIR)/$(ephemeral-port-reserve_dist_name): SHELL:=/bin/bash
$(call gen_fetch_rules,ephemeral-port-reserve,\
                       ephemeral-port-reserve_dist_name,\
                       fetch_ephemeral-port-reserve_dist)

define xtract_ephemeral-port-reserve
$(call rmrf,$(srcdir)/ephemeral-port-reserve)
$(call untar,$(srcdir)/ephemeral-port-reserve,\
             $(FETCHDIR)/$(ephemeral-port-reserve_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,ephemeral-port-reserve,xtract_ephemeral-port-reserve)

$(call gen_dir_rules,ephemeral-port-reserve)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-ephemeral-port-reserve,stage-python)

$(call gen_python_module_rules,stage-ephemeral-port-reserve,\
                               ephemeral-port-reserve,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-ephemeral-port-reserve,stage-python)

$(call gen_python_module_rules,final-ephemeral-port-reserve,\
                               ephemeral-port-reserve,\
                               $(PREFIX),\
                               $(finaldir))
