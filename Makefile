MPP_OPTIONS = -so '((!' -sc '!))' -son '{{!' -scn '!}}' -soc '' -scc '' -sec '' -sos '{{<' -scs '>}}' -its 
MPP = mpp ${MPP_OPTIONS}

all:html-pages/static pkg opamdoc
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


include .pkg

# TODO : move pkg to md-pages
.pkg:pkg-pages/*.html pkg-pages/*/*/index.html Makefile main_tpl.mpp core_tpl.mpp navbar_tpl.mpp 
	for i in pkg-pages/*.html pkg-pages/*/*/index.html ; do echo "$$(sed -e 's+pkg-pages+html-pages/pkg+' <<< $$i):$$i  main_tpl.mpp core_tpl.mpp navbar_tpl.mpp" ; printf '\tmkdir -p %s\n' "$$(dirname $$(sed -e s+pkg-pages+html-pages/pkg+ <<< $$i))"; printf '\t%s\n' "${MPP} -set page=$$i < main_tpl.mpp > $$(sed -e s+pkg-pages+html-pages/pkg+ <<< $$i)" ; done > $@

pkg:
	make .pkg
	for i in pkg-pages/*.html pkg-pages/*/*/index.html ; do \
	sed -e 's|pkg-pages|html-pages/pkg|' <<< $$i ; \
	done | xargs make

.PHONY:pkg clean



# include .opamdoc
# TODO : move opamhtml to md-pages
opamdoc:
	mkdir -p html-pages/docs/opam/
	rsync opamhtml/doc_loader.js html-pages/docs/opam/
	rm -fr html-pages/docs/opam
	cp -r opamhtml html-pages/docs/opam
	rm -f html-pages/docs/opam/index.html

.PHONY:pkg clean opamdoc

