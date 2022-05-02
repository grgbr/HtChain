
pkg_url     := https://github.com/mesonbuild/meson/releases/download/0.62.1/meson-0.62.1.tar.gz
sig_url     := $(pkg_url).asc
tarball     := $(FETCHDIR)/$(notdir $(pkg_url))
fetch_dists := $(tarball)

include $(TOPDIR)/rules.mk

define fetch_cmds
$(call download_verify_detach,$(pkg_url),$(sig_url),$(tarball))
endef

define xtract_cmds
$(call untar,$(SRCDIR),$(tarball),--strip-components=1)
endef

define build_cmds
cd $(SRCDIR) && \
env LD_LIBRARY_PATH="$(STAGEDIR)$(PREFIX)/lib" \
$(STAGEDIR)$(PREFIX)/bin/python3 -s \
	setup.py $(if $(V),--verbose) \
	         build --force \
	               --build-base "$(BUILDDIR)" \
	               --executable "$(PREFIX)/bin/python3"
endef

define clean_cmds
+$(MAKE) -C $(BUILDDIR) clean
endef

define install_cmds
cd $(SRCDIR) && \
env LD_LIBRARY_PATH="$(STAGEDIR)$(PREFIX)/lib" \
$(STAGEDIR)$(PREFIX)/bin/python3 -s \
	setup.py $(if $(V),--verbose) \
	         build --build-base "$(BUILDDIR)" \
	               --executable "$(PREFIX)/bin/python3" \
	         install --force \
	                 --root "$(STAGEDIR)" \
	                 --prefix "$(PREFIX)" \
	                 --compile --optimize 2 \
	                 --record "$(BUILDDIR)/.installed"
sed -i '1c#!$(PREFIX)/bin/python3' $(STAGEDIR)$(PREFIX)/bin/meson
endef

define uninstall_cmds
if [ -f "$(BUILDDIR)/.installed" ]; then \
	while read ln; do \
		$(RM) "$$ln"; \
	done < $(BUILDDIR)/.installed; \
	$(RM) "$(BUILDDIR)/.installed"; \
fi
endef
