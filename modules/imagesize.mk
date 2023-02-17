################################################################################
# idna Python modules
################################################################################

imagesize_dist_url  := https://files.pythonhosted.org/packages/a7/84/62473fb57d61e31fef6e36d64a179c8781605429fd927b5dd608c997be31/imagesize-1.4.1.tar.gz
imagesize_dist_sum  := f191d7fe34a01ab21b0f4f6519df8ab2a53c1ca54956f4d825d9cec5bd5f4c569491bdc26cb36fcaad2c453c35e51f69379f091362e206453aaefbda4802daa4
imagesize_dist_name := $(notdir $(imagesize_dist_url))
imagesize_vers      := $(patsubst imagesize-%.tar.gz,%,$(imagesize_dist_name))
imagesize_brief     := Python_ module for getting image size from png/jpeg/jpeg2000/gif file
imagesize_home      := https://github.com/shibukawa/imagesize_py

define imagesize_desc
This small module parses image header and returns width and height of the image.
Supported formats are: PNG/JPEG/JPEG2000/GIF.
endef

define fetch_imagesize_dist
$(call download_csum,$(imagesize_dist_url),\
                     $(FETCHDIR)/$(imagesize_dist_name),\
                     $(imagesize_dist_sum))
endef
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

check_stage-imagesize = $(call imagesize_check_cmds,stage-imagesize)

$(call gen_deps,stage-imagesize,stage-wheel)
$(call gen_python_module_rules,stage-imagesize,imagesize,$(stagedir))

################################################################################
# Final definitions
################################################################################

check_final-imagesize = $(call imagesize_check_cmds,final-imagesize)

$(call gen_deps,final-imagesize,stage-wheel)
$(call gen_python_module_rules,final-imagesize,\
                               imagesize,\
                               $(PREFIX),\
                               $(finaldir))
