MKDIR := mkdir
CURL  := curl
TAR   := tar
TOUCH := touch

define download
$(CURL) '$(1)' --output '$(2)'
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
