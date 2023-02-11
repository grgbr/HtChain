################################################################################
# snowballstemmer Python modules
################################################################################

snowballstemmer_dist_url  := https://files.pythonhosted.org/packages/44/7b/af302bebf22c749c56c9c3e8ae13190b5b5db37a33d9068652e8f73b7089/snowballstemmer-2.2.0.tar.gz
snowballstemmer_dist_sum  := f1dee83e06fc79ffb250892fe62c75e3393b9af07fbf7cde413e6391870aa74934302771239dea5c9bc89806684f95059b00c9ffbcf7340375c9dd8f1216cd37
snowballstemmer_dist_name := $(notdir $(snowballstemmer_dist_url))
snowballstemmer_vers      := $(patsubst snowballstemmer-%.tar.gz,%,$(snowballstemmer_dist_name))
snowballstemmer_brief     := Pure Python_ Snowball stemming library
snowballstemmer_home      := https://github.com/snowballstem/snowball

define snowballstemmer_desc
Snowball provides access to efficient algorithms for calculating a "stemmed"
form of a word.  This is a form with most of the common morphological endings
removed; hopefully representing a common linguistic base form.  This is most
useful in building search engines and information retrieval software; for
example, a search with stemming enabled should be able to find a document
containing "cycling" given the query "cycles".

Snowball provides algorithms for several (mainly European) languages.  It also
provides access to the classic Porter stemming algorithm for English: although
this has been superseded by an improved algorithm, the original algorithm may be
of interest to information retrieval researchers wishing to reproduce results of
earlier experiments.
endef

define fetch_snowballstemmer_dist
$(call download_csum,$(snowballstemmer_dist_url),\
                     $(FETCHDIR)/$(snowballstemmer_dist_name),\
                     $(snowballstemmer_dist_sum))
endef
$(call gen_fetch_rules,snowballstemmer,\
                       snowballstemmer_dist_name,\
                       fetch_snowballstemmer_dist)

define xtract_snowballstemmer
$(call rmrf,$(srcdir)/snowballstemmer)
$(call untar,$(srcdir)/snowballstemmer,\
             $(FETCHDIR)/$(snowballstemmer_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,snowballstemmer,xtract_snowballstemmer)

$(call gen_dir_rules,snowballstemmer)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-snowballstemmer,stage-wheel)

$(call gen_python_module_rules,stage-snowballstemmer,\
                               snowballstemmer,\
                               $(stagedir))

################################################################################
# Final definitions
################################################################################

$(call gen_deps,final-snowballstemmer,stage-wheel)

$(call gen_python_module_rules,final-snowballstemmer,\
                               snowballstemmer,\
                               $(PREFIX),\
                               $(finaldir))
