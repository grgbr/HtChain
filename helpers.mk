MKDIR := mkdir
CURL  := curl
GPG   := gpg
TAR   := tar
TOUCH := touch

define download
$(CURL) --silent '$(1)' --output '$(2)'
endef

define gpg_verify_detach
$(GPG) --batch \
       --homedir $(FETCHDIR)/.gnupg \
       --log-file /dev/null \
       --verify $(1) $(2)
endef

define mkdir
$(MKDIR) --parents '$(1)'
endef

define rmrf
$(RM) --recursive '$(1)'
endef

define rmf
$(RM) '$(1)'
endef

define untar
$(MKDIR) --parents '$(BUILDDIR)'
$(TAR) --extract --directory='$(BUILDDIR)' --file='$(1)' $(2)
endef

define touch
$(TOUCH) '$(1)'
endef

$(FETCHDIR) $(BUILDDIR) $(STAMPDIR):
	$(call mkdir,$(@))
