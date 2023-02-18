################################################################################
# cheetah3 modules
################################################################################

cheetah3_dist_url  := https://files.pythonhosted.org/packages/23/33/ace0250068afca106c1df34348ab0728e575dc9c61928d216de3e381c460/Cheetah3-3.2.6.post1.tar.gz
cheetah3_dist_sum  := 69b82ccf31930c50ffdcbc7608683a8456d8025ca3633b0637d16de64aa9337f5f65da86d54bb2b3aa41722f25727a503307b5a7cc80a13d74f332117d6ca05e
cheetah3_vers      := $(patsubst Cheetah3-%.post1.tar.gz,%,\
                                 $(notdir $(cheetah3_dist_url)))
cheetah3_dist_name := cheetah3-$(cheetah3_vers).tar.gz
cheetah3_brief     := Text-based template engine and Python_ code generator
cheetah3_home      := https://cheetahtemplate.org/

define cheetah3_desc
Cheetah can be used as a standalone templating utility or referenced as a
library from other Python_ applications. It has many potential uses, but web
developers looking for a viable alternative to ASP, JSP, PHP and PSP are
expected to be its principle user group.

Features:

   * generates HTML, SGML, XML, SQL, Postscript, form email, LaTeX, or any other
     text-based format ;
   * cleanly separates content, graphic design, and program code.
   * blends the power and flexibility of Python_ with a simple template language
     that non-programmers can understand ;
   * gives template writers full access to any Python_ data structure, module,
     function, object, or method in their templates ;
   * makes code reuse easy by providing an object-orientated interface to
     templates that is accessible from Python_ code or other Cheetah templates ;
     one template can subclass another and selectively reimplement sections of
     it ;
   * provides a simple, yet powerful, caching mechanism that can dramatically
     improve the performance of a dynamic website ;
   * compiles templates into optimized, yet readable, Python_ code.
endef

define fetch_cheetah3_dist
$(call download_csum,$(cheetah3_dist_url),\
                     $(FETCHDIR)/$(cheetah3_dist_name),\
                     $(cheetah3_dist_sum))
endef
$(call gen_fetch_rules,cheetah3,cheetah3_dist_name,fetch_cheetah3_dist)

define xtract_cheetah3
$(call rmrf,$(srcdir)/cheetah3)
$(call untar,$(srcdir)/cheetah3,\
             $(FETCHDIR)/$(cheetah3_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,cheetah3,xtract_cheetah3)

$(call gen_dir_rules,cheetah3)

# $(1): targets base name / module name
define cheetah3_check_cmds
cd $(builddir)/$(strip $(1)) && \
env PATH="$(stagedir)/bin:$(PATH)" \
    LD_LIBRARY_PATH="$(stage_lib_path)" \
$(stage_python) Cheetah/Tests/Test.py
endef

################################################################################
# Staging definitions
################################################################################

check_stage-cheetah3 = $(call cheetah3_check_cmds,stage-cheetah3)

$(call gen_deps,stage-cheetah3,stage-markdown stage-pygments)
$(call gen_check_deps,stage-cheetah3,stage-cheetah3)
$(call gen_python_module_rules,stage-cheetah3,\
                               cheetah3,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

final-cheetah3_shebang_fixups := bin/cheetah \
                                 bin/cheetah-compile \
                                 bin/cheetah-analyze \
                                 $(addprefix $(python_site_path_comp)/,\
                                             Cheetah/Filters.py \
                                             Cheetah/Version.py \
                                             Cheetah/DirectiveAnalyzer.py \
                                             Cheetah/Templates/SkeletonPage.py \
                                             Cheetah/Tests/Performance.py \
                                             Cheetah/Tests/Test.py \
                                             Cheetah/Tests/CheetahWrapper.py \
                                             Cheetah/NameMapper.py \
                                             Cheetah/Tools/SiteHierarchy.py \
                                             Cheetah/Servlet.py \
                                             Cheetah/CheetahWrapper.py)

final-cheetah3_ext_lib_names := _namemapper

final-cheetah3_rpath_fixups = \
	$(addprefix $(python_site_path_comp)/Cheetah/,\
	            $(addsuffix $(python_ext_lib_suffix),\
	                        $(final-cheetah3_ext_lib_names)))

define install_final-cheetah3
$(call python_module_install_cmds,final-cheetah3,$(PREFIX),$(finaldir))
$(call fixup_shebang,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-cheetah3_shebang_fixups)),\
       $(PREFIX)/bin/python)
$(call fixup_rpath,\
       $(addprefix $(finaldir)$(PREFIX)/,$(final-cheetah3_rpath_fixups)),\
       $(final_lib_path))
endef

check_final-cheetah3 = $(call cheetah3_check_cmds,final-cheetah3)

$(call gen_deps,final-cheetah3,stage-markdown stage-pygments)
$(call gen_check_deps,final-cheetah3,stage-cheetah3)
$(call gen_python_module_rules,final-cheetah3,\
                               cheetah3,\
                               $(PREFIX),\
                               $(finaldir))
