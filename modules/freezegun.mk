################################################################################
# freezegun Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

freezegun_dist_url  := https://files.pythonhosted.org/packages/1d/97/002ac49ec52858538b4aa6f6831f83c2af562c17340bdf6043be695f39ac/freezegun-1.2.2.tar.gz
freezegun_dist_sum  := c6dc3da66a2d3063f819a104b6bc98eb3d4b772b8edb06bde130a6e355d96e1861e650c44eb691be892223150a652a528fda4237bd77b1bdcee1fcfad74f307c
freezegun_dist_name := $(notdir $(freezegun_dist_url))
freezegun_vers      := $(patsubst freezegun-%.tar.gz,%,$(freezegun_dist_name))
freezegun_brief     := Python_ library to mock the datetime module in unit testing
freezegun_home      := https://github.com/spulec/freezegun

define freezegun_desc
FreezeGun allows easy mocking of the datetime module by freezing the return
value of the methods ``datetime.datetime.now()``,
``datetime.datetime.utcnow()``, ``datetime.date.today()``, and ``time.time()``
to a fixed point in time. Use it in unit testing to make the tests deterministic
and time-independent.
endef

define fetch_freezegun_dist
$(call download_csum,$(freezegun_dist_url),\
                     $(freezegun_dist_name),\
                     $(freezegun_dist_sum))
endef
$(call gen_fetch_rules,freezegun,freezegun_dist_name,fetch_freezegun_dist)

define xtract_freezegun
$(call rmrf,$(srcdir)/freezegun)
$(call untar,$(srcdir)/freezegun,\
             $(FETCHDIR)/$(freezegun_dist_name),\
             --strip-components=1)
cd $(srcdir)/freezegun && \
patch -p1 < $(PATCHDIR)/freezegun-1.2.2-000-fix_helper_static_method_call.patch
endef
$(call gen_xtract_rules,freezegun,xtract_freezegun)

$(call gen_dir_rules,freezegun)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-freezegun,stage-python-dateutil)

$(call gen_python_module_rules,stage-freezegun,freezegun,$(stagedir))
