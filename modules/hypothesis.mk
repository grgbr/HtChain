################################################################################
# hypothesis Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

hypothesis_dist_url  := https://files.pythonhosted.org/packages/0b/a7/08f79b065d9b9cc2306aa1634c9cc5024e728d4629abb364b19c36e91afa/hypothesis-6.62.1.tar.gz
hypothesis_dist_sum  := aeddaac78795308130d7445d15211fd3ff27032b31c4a3ca9c5e4cf49feeb55045f31d33caafcade087cdaaeed02350b4a57e2031f89203f7642dc9e1639a7f6
hypothesis_dist_name := $(notdir $(hypothesis_dist_url))
hypothesis_vers      := $(patsubst hypothesis-%.tar.gz,%,$(hypothesis_dist_name))
hypothesis_brief     := Advanced Quickcheck style testing library for Python_
hypothesis_home      := https://hypothesis.works/

define hypothesis_desc
Hypothesis is a library for testing your Python_ code against a much larger
range of examples than you would ever want to write by hand. It's based on the
Haskell library, Quickcheck, and is designed to integrate seamlessly into your
existing Python_ unit testing work flow.

Hypothesis is both extremely practical and also advances the state of the art of
unit testing by some way. It's easy to use, stable, and extremely powerful. If
you're not using Hypothesis to test your project then you're missing out.
endef

define fetch_hypothesis_dist
$(call download_csum,$(hypothesis_dist_url),\
                     $(FETCHDIR)/$(hypothesis_dist_name),\
                     $(hypothesis_dist_sum))
endef
$(call gen_fetch_rules,hypothesis,hypothesis_dist_name,fetch_hypothesis_dist)

define xtract_hypothesis
$(call rmrf,$(srcdir)/hypothesis)
$(call untar,$(srcdir)/hypothesis,\
             $(FETCHDIR)/$(hypothesis_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,hypothesis,xtract_hypothesis)

$(call gen_dir_rules,hypothesis)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-hypothesis,\
                stage-attrs stage-exceptiongroup stage-sortedcontainers)

$(call gen_python_module_rules,stage-hypothesis,hypothesis,$(stagedir))
