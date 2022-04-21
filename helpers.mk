MKDIR := mkdir
CURL  := curl
GPG   := gpg
TAR   := tar
TOUCH := touch
MV    := mv
SYNC  := sync

define _download
$(CURL) --silent '$(1)' --output '$(2)'
endef

define gpg_verify_detach
$(GPG) --batch \
       --homedir $(FETCHDIR)/.gnupg \
       --log-file /dev/null \
       --verify '$(1)' '$(2)'
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

define mv
$(MV) '$(1)' '$(2)'
endef

define download
$(call _download,$(1),$(2).tmp)
$(call mv,$(2).tmp,$(2))
$(SYNC) --file-system '$(2)'
endef

define download_verify_detach
$(call _download,$(1),$(3).tmp)
$(call _download,$(2),$(3).sig)
$(call gpg_verify_detach,$(3).sig,$(3).tmp)
$(call mv,$(3).tmp,$(3))
$(SYNC) --file-system '$(3)'
endef

$(FETCHDIR) $(BUILDDIR) $(STAMPDIR):
	$(call mkdir,$(@))
