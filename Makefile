MDBOOK_RELEASE=https://github.com/rust-lang/mdBook/releases/download/v0.4.1/mdbook-v0.4.1-x86_64-unknown-linux-gnu.tar.gz
KATEX_RELEASE=https://github.com/KaTeX/KaTeX/releases/download/v0.12.0/katex.tar.gz
DEPS=bin/mdbook mdbook-katex/katex/katex.min.js

.PHONY: book serve


book: $(DEPS)
	bin/mdbook build

serve: $(DEPS)
	bin/mdbook serve

bin/mdbook:
	cd bin; curl -sL '$(MDBOOK_RELEASE)' | tar xzv

mdbook-katex/katex/katex.min.js:
	cd mdbook-katex; curl -sL '$(KATEX_RELEASE)' | tar xz
