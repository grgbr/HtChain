################################################################################
# setuptools-rust Python modules
#
# Module required for check targets only. Do not bother verifying it to prevent
# from fetching loads of dependencies.
################################################################################

setuptools-rust_dist_url  := https://files.pythonhosted.org/packages/99/db/e4ecb483ffa194d632ed44bda32cb740e564789fed7e56c2be8e2a0e2aa6/setuptools-rust-1.5.2.tar.gz
setuptools-rust_dist_sum  := 79b1de5581b9558cdf227320c421aa2445b2e6b8583ed9c118ee8d7acdfde9d947e7d11fa6a9697c475d4ca387c86ca6846429099ec30d2eb6e40f8849fcecc0
setuptools-rust_dist_name := $(notdir $(setuptools-rust_dist_url))
setuptools-rust_vers      := $(patsubst setuptools-rust-%.tar.gz,%,$(setuptools-rust_dist_name))
setuptools-rust_brief     := Setuptools Rust extension plugin
setuptools-rust_home      := https://github.com/PyO3/setuptools-rust

define setuptools-rust_desc
setuptools-rust is a plugin for setuptools to build Rust Python_ extensions
implemented with `PyO3 <https://github.com/pyo3/pyo3>`_ or
`rust-cpython <https://github.com/dgrunwald/rust-cpython>`_.

Compile and distribute Python_ extensions written in Rust as easily as if they
were written in C.
endef

define fetch_setuptools-rust_dist
$(call download_csum,$(setuptools-rust_dist_url),\
                     $(FETCHDIR)/$(setuptools-rust_dist_name),\
                     $(setuptools-rust_dist_sum))
endef
$(call gen_fetch_rules,setuptools-rust,\
                       setuptools-rust_dist_name,\
                       fetch_setuptools-rust_dist)

define xtract_setuptools-rust
$(call rmrf,$(srcdir)/setuptools-rust)
$(call untar,$(srcdir)/setuptools-rust,\
             $(FETCHDIR)/$(setuptools-rust_dist_name),\
             --strip-components=1)
endef
$(call gen_xtract_rules,setuptools-rust,xtract_setuptools-rust)

$(call gen_dir_rules,setuptools-rust)

################################################################################
# Staging definitions
################################################################################

$(call gen_deps,stage-setuptools-rust,\
                stage-typing-extensions stage-semantic-version)

$(call gen_python_module_rules,stage-setuptools-rust,\
                               setuptools-rust,\
                               $(stagedir))
