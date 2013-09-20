MPP_OPTIONS = -so '((!' -sc '!))' -son '{{!' -scn '!}}' -soc '' -scc '' -sec '' -sos '{{<' -scs '>}}' -its 
MPP = mpp ${MPP_OPTIONS}

all:html-pages/static pkg
	bash gen.bash md-pages

html-pages/try-ocaml.js:try-ocaml.js
	cp try-ocaml.js html-pages/

html-pages/%.html:md-pages/%.md Makefile main_tpl.mpp core_tpl.mpp navbar_tpl.mpp htmlescape ocamlapplet.bash ocamltohtml html-pages/try-ocaml.js 
	if grep -q '*Table of contents*' "$<" ; then omd -otoc -ts 2 "$<" > "$@.toc" ; fi
	sed -e 's|\*Table of contents\*||g' "$<" | omd -r ocaml=./ocamlapplet.bash > "$@.tmp"
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

clean:
	rm -fr html-pages *~

htmlescape:htmlescape.ml
	ocamlopt $< -o $@

ocamltohtml:ocamltohtml_all.ml
	ocamlopt $< -o $@

md-pages/pkg:pkg-pages
	make pkg
md-pages/pkg/docs:opamhtml
	make pkg

pkg:
	rm -fr md-pages/pkg/
	mkdir -p md-pages/pkg/docs/
	rsync -r pkg-pages/* md-pages/pkg/
	find md-pages/pkg -iname '*.html' -type f -exec mv {} {}.mpp ';'
	rsync -r opamhtml/* md-pages/pkg/docs/
	rm -f md-pages/pkg/docs/index.html

	find md-pages/pkg -iname '*.html.mpp'|while read l ; do \
		if [[ -d md-pages/pkg/docs/"$$(basename $$(dirname $$(dirname "$$l")))" ]] ; then \
			frag -tr '.*</tbody>' < "$$l" > "$$l".p1 ;\
			frag -fr '.*</tbody>' < "$$l" > "$$l".p3 ;\
			printf '<tr><th>Documentation??</th><td><a href="docs/?package=%s"></a></td></tr>\n          </tbody>\n' \
					"$$(basename $$(dirname $$(dirname "$$l")))" > "$$l".p2 ;\
			cat "$$l".p1 "$$l".p2 "$$l".p3 > "$$l" ;\
		fi; \
	done

	echo '<!-- Unfortunately, this file is generated, so do not edit manually. {{! set title opam packages documentation !}} -->' > md-pages/pkg/docs/index.md
	echo '<div id="opamdoc-contents">' >> md-pages/pkg/docs/index.md
	frag -fr '.*<body.*' -tr '.*</body>.*' < opamhtml/index.html >> md-pages/pkg/docs/index.md
	echo '</div>' >> md-pages/pkg/docs/index.md
	echo '<script type="text/javascript" src="opam_doc_loader.js"></script>' >> md-pages/pkg/docs/index.md
	echo '<script type="text/javascript">opamdoc_contents = document.getElementById("opamdoc-contents");</script>' >> md-pages/pkg/docs/index.md


.PHONY: opamdoc pkg clean

