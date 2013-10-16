# auto-generated files, deleted by distclean
AUTOFILES = src/lib/ocamlorg.ml \
            src/lib/ocamlorg.mli \
            setup.ml

default: web all

# build the website
WWW = www
.PHONY: web web-stop-on-error post-build
web: build
	if [ -x ./build.native ]; then ./build.native; else ./build.byte; fi
	$(MAKE) post-build

web-stop-on-error: build
	if [ -x ./build.native ]; then ./build.native --stop-on-error; \
	else ./build.byte --stop-on-error; fi
	$(MAKE) post-build

post-build:
	cp -a src/html/css $(WWW)
	cp -a src/html/js $(WWW)
	cp -a src/html/ext/bootstrap/css/*.css $(WWW)/css/
	cp -a src/html/ext/bootstrap/js $(WWW)/
	cp -a src/html/ext/*.js $(WWW)/js/
	cp -a src/html/img $(WWW)
	cp -a src/html/ext/bootstrap/img/*.png $(WWW)/img/
	cp -a src/html/CNAME $(WWW)/
	cp -a src/html/meetings/ocaml/2013/proposals src/html/meetings/ocaml/2013/slides $(WWW)/meetings/ocaml/2013/

src/lib/ocamlorg.ml src/lib/ocamlorg.mli: src/lib/ocamlorg.html src/lib/ocamlorg.html.ml src/lib/ocamlorg.html.mli
	cd src/lib; weberizer ocamlorg.html

setup.ml: _oasis
	oasis setup -setup-update dynamic

SETUP = ocaml setup.ml

setup.data: setup.ml src/lib/ocamlorg.html src/lib/ocamlorg.html.ml src/lib/ocamlorg.html.mli
	$(SETUP) -configure $(CONFIGUREFLAGS)

configure: setup.data

build: setup.data src/lib/ocamlorg.ml src/lib/ocamlorg.mli
	$(SETUP) -build $(BUILDFLAGS)

doc: setup.data build
	$(SETUP) -doc $(DOCFLAGS)

test: setup.data build
	$(SETUP) -test $(TESTFLAGS)

all: setup.ml
	$(SETUP) -all $(ALLFLAGS)

install: setup.data
	$(SETUP) -install $(INSTALLFLAGS)

uninstall: setup.data
	$(SETUP) -uninstall $(UNINSTALLFLAGS)

reinstall: setup.data
	$(SETUP) -reinstall $(REINSTALLFLAGS)

clean:: setup.ml
	$(SETUP) -clean $(CLEANFLAGS)

distclean:: setup.ml
	$(SETUP) -distclean $(DISTCLEANFLAGS)
	$(RM) -r $(WWW)
	$(RM) $(AUTOFILES)

publish:
	git checkout publish
	git pull
	$(MAKE) web-stop-on-error
	commit=`git log -1 --pretty=format:%H`; \
	temp=`mktemp -d temp-gh-pages.XXXXX`; \
	git clone git@github.com:ocaml/ocaml.org.git $$temp -b gh-pages && \
	rsync -av --delete --exclude=.git www/ $$temp && \
	cd $$temp && \
	git add --all . && \
	git commit -a -m "publish $$commit" && \
	git push && \
	cd .. && \
	rm -rf $$temp

.PHONY: build doc test all install uninstall reinstall clean distclean configure publish

######################################################################
## New version of the web site

MPP_OPTIONS = -so '((!' -sc '!))' -son '{{!' -scn '!}}' -soc '' -scc '' -sec '' -sos '{{<' -scs '>}}' -its 
MPP = mpp ${MPP_OPTIONS}

all:html-pages/static md-pages/pkg md-pages/pkg/docs
	bash gen.bash md-pages

html-pages/try-ocaml.js:try-ocaml.js
	cp try-ocaml.js html-pages/

html-pages/%.html:md-pages/%.md Makefile main_tpl.mpp core_tpl.mpp navbar_tpl.mpp htmlescape ocamlapplet.bash ocamltohtml html-pages/try-ocaml.js 
	if grep -q '*Table of contents*' "$<" ; then omd -otoc -ts 2 "$<" > "$@.toc" ; fi
	sed -e 's|\*Table of contents\*||g' "$<" | omd -r ocaml=./ocamltohtml -r tryocaml=./ocamlapplet.bash > "$@.tmp"
	if [ -f "$@.toc" ] ; then \
	${MPP} -set "filename=$<" -set "page=$@.tmp" -set "toc=$@.toc" < main_tpl.mpp > "$@" ; \
	rm -f "$@.toc" ; \
	else \
	${MPP} -set "filename=$<" -set "page=$@.tmp" < main_tpl.mpp > "$@" ; \
	fi
#	temporary hack for tryocaml to work:
#	sed -e 's|<pre><code |<pre |g' -e 's|</code></pre>|</pre>|g' "$@" > "$@.tmp"
#	mv "$@.tmp" "$@"
	rm -f "$@.tmp"

html-pages/img:skin/img
	rm -fr "$@"
	mkdir -p html-pages
	cp -a "$<" "$@"

html-pages/static:skin/static skin/static/css skin/static/img
	rm -fr "$@"
	mkdir -p $@
	cp -a "$<"/* "$@"/

html-pages/static/css:skin/static/css
	rm -fr html-pages/static
	make html-pages/static
html-pages/static/img:skin/static/img
	rm -fr html-pages/static
	make html-pages/static

clean::
	rm -fr html-pages *~

htmlescape:htmlescape.ml
	ocamlopt $< -o $@

ocamltohtml:lexer.ml ocamltohtml.ml
	ocamlopt $+ -o $@

md-pages/pkg:pkg-pages Makefile
	make pkg
md-pages/pkg/docs:opamhtml Makefile
	make pkg

pkg:Makefile
	rm -fr md-pages/pkg/
	mkdir -p md-pages/pkg/docs/
	rsync -r pkg-pages/* md-pages/pkg/

	mv md-pages/pkg/index.{html,md}

	for l in md-pages/pkg/*/*/*.html ; do \
	  (printf '<!-- {{! set title %s !}} -->\n' "$$(basename $$(dirname $$l))" ; cat "$$l") \
		> "$$(dirname $$l)/$$(basename $$l html)"md ;\
	  rm -f "$$l" ;\
	done

	printf '<!-- {{! set title Packages !}} -->\n# Packages\n' > md-pages/pkg/index.html
	cat md-pages/pkg/index.md >> md-pages/pkg/index.html
	mv md-pages/pkg/index.html md-pages/pkg/index.md
	rsync -r opamhtml/* md-pages/pkg/docs/
	rm -f md-pages/pkg/docs/index.html

	find md-pages/pkg/* -iname '*.md'|while read l ; do \
		if [[ -d md-pages/pkg/docs/"$$(basename $$(dirname $$(dirname "$$l")))" ]] ; then \
			frag -tr '.*</tbody>' < "$$l" > "$$l".p1 ;\
			frag -fr '.*</tbody>' < "$$l" > "$$l".p3 ;\
			printf '<tr><th>Documentation</th><td><a href="/pkg/docs/?package=%s">click here...</a></td></tr>\n          </tbody>\n' \
					"$$(basename $$(dirname $$(dirname "$$l")))" > "$$l".p2 ;\
			cat "$$l".p1 "$$l".p2 "$$l".p3 > "$$l" ;\
		fi; \
	done

	echo '<!-- Unfortunately, this file is generated, so do not edit manually. {{! set title Packages Documentation !}} -->' > md-pages/pkg/docs/index.md
	echo '<div id="opamdoc-contents" class="span8 offset2"><h1>List of Packages</h1><table class="indextable">' >> md-pages/pkg/docs/index.md
	frag -fr '.*<table.*' -tr '.*</table>.*' < opamhtml/index.html | sort >> md-pages/pkg/docs/index.md
	echo '</table></div>' >> md-pages/pkg/docs/index.md
	echo '<script type="text/javascript" src="opam_doc_loader.js"></script>' >> md-pages/pkg/docs/index.md
	echo '<script type="text/javascript">opamdoc_contents = document.getElementById("opamdoc-contents");</script>' >> md-pages/pkg/docs/index.md


.PHONY: opamdoc pkg clean


html-pages/learn/index.html:front_code_snippet_tpl.html
html-pages/index.html:front_code_snippet_tpl.html front_news_tpl.mpp
front_code_snippet_tpl.html:front_code_snippet_tpl.md
	omd -r ocaml=./ocamltohtml -r tryocaml=./ocamlapplet.bash $< > $@
