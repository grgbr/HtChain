################################################################################
# blinker modules
################################################################################

# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.

blinker_dist_url  := https://files.pythonhosted.org/packages/2b/12/82786486cefb68685bb1c151730f510b0f4e5d621d77f245bc0daf9a6c64/blinker-1.5.tar.gz
blinker_dist_sum  := b1880fdc974be63e16e2b826bdbc8ee161bc0234591b8b41deed937a1e1b9d0bf1fb697c8e94644de9cc1900aedd39d08cfc3e59fef51abec295552f96418722
blinker_dist_name := $(notdir $(blinker_dist_url))
blinker_vers      := $(patsubst blinker-%.tar.gz,%,$(blinker_dist_name))
blinker_brief     := Fast, simple Python_ object-to-object and broadcast signaling library
blinker_home      := https://blinker.readthedocs.io/

define blinker_desc
Blinker provides a fast dispatching system that allows any number of
interested parties to subscribe to events, or "signals".

Signal receivers can subscribe to specific senders or receive signals
sent by any sender.
endef

define fetch_blinker_dist
$(call download_csum,$(blinker_dist_url),\
                     $(FETCHDIR)/$(blinker_dist_name),\
                     $(blinker_dist_sum))
endef
$(call gen_fetch_rules,blinker,blinker_dist_name,fetch_blinker_dist)

define xtract_blinker
$(call rmrf,$(srcdir)/blinker)
$(call untar,$(srcdir)/blinker,\
             $(FETCHDIR)/$(blinker_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,blinker,xtract_blinker)

$(call gen_dir_rules,blinker)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-blinker,stage-wheel)

$(call gen_python_module_rules,stage-blinker,blinker,$(stagedir))
