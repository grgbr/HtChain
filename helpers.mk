MKDIR := mkdir
CURL  := curl
GPG   := gpg
TAR   := tar
TOUCH := touch
MV    := mv
SYNC  := sync
RSYNC := rsync

empty :=

comma := ,

space := $(empty) $(empty)

# Location where to find various script utilities
scriptdir := $(TOPDIR)/scripts

define newline
$(empty)
$(empty)
endef

# Use --location for sites where URL points to a page that has moved to a
# different location, e.g. github.
define _download
$(CURL) --silent --location '$(strip $(1))' --output '$(strip $(2))'
endef

define gpg_verify_detach
$(scriptdir)/gpg_verify.sh --homedir "$(FETCHDIR)/.gnupg" \
                           '$(strip $(1))' \
                           '$(strip $(2))'
endef

define mkdir
$(MKDIR) --parents '$(strip $(1))'
endef

define rmrf
$(RM) --recursive '$(strip $(1))'
endef

define rmf
$(RM) '$(strip $(1))'
endef

define untar
$(MKDIR) --parents '$(strip $(1))'
$(TAR) --extract \
       --directory='$(strip $(1))' \
       --file='$(strip $(2))' \
       $(strip $(3))
endef

define touch
$(TOUCH) '$(strip $(1))'
endef

define mv
$(MV) '$(strip $(1))' '$(strip $(2))'
endef

define download
if [ ! -r "$(strip $(2))" ]; then \
	$(call _download,$(1),$(strip $(2)).tmp) && \
	$(call mv,$(strip $(2)).tmp,$(2)) && \
	$(SYNC) --file-system '$(strip $(2))'; \
fi
endef

define download_verify_detach
if [ ! -r "$(strip $(3))" ]; then \
	$(call _download,$(1),$(strip $(3)).tmp) && \
	$(call _download,$(2),$(strip $(3)).sig) && \
	$(call gpg_verify_detach,$(strip $(3)).sig,$(strip $(3)).tmp) && \
	$(call mv,$(strip $(3)).tmp,$(3)) && \
	$(SYNC) --file-system '$(strip $(3))'; \
fi
endef

define setup_pkgs_cmds
sudo apt-get --assume-yes update
sudo apt-get --assume-yes --no-upgrade install $(DEBSRCDEPS)
endef

define setup_sigs_cmds
$(scriptdir)/gpg_setup.sh $(FETCHDIR)
endef

define _mirror_cmd
umask=0022 && \
$(RSYNC) --recursive \
         --links \
         --devices \
         --specials \
         --perms \
         --chmod=Dg-w,Dg+rx,Do-w,Do+rx,Fg-w,Fg+r,Fo-w,Fo+r \
         --info=progress2 \
         '$(strip $(1))/' '$(strip $(2))'
endef


define mirror_cmd
$(if $(realpath $(strip $(1))),,$(error '$(strip $(1))': Invalid mirror destination))
$(call rmrf,$(2))
$(call _mirror_cmd,$(1),$(2))
endef

define strip_cmd
umask=0022 && $(scriptdir)/strip.sh '$(strip $(1))'
endef
