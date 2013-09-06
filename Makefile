MPP_OPTIONS = -so '((!' -sc '!))' -son '{{!' -scn '!}}' -soc '' -scc '' -sec '' -its 
MPP = mpp ${MPP_OPTIONS}

all:html-pages/static
	bash gen.bash md-pages

html-pages/%.html:md-pages/%.md Makefile main_tpl.mpp navbar_tpl.mpp
	if grep -q '*Table of contents*' "$<" ; then omd -otoc -ts 2 "$<" > "$@.toc" ; fi
	sed -e 's|\*Table of contents\*||g' "$<" | omd -r ocaml=ocamltohtml > "$@.tmp"
	if [ -f "$@.toc" ] ; then \
	${MPP} -set "page=$@.tmp" -set "toc=$@.toc" < main_tpl.mpp > "$@" ; \
	rm -f "$@.toc" ; \
	else \
	${MPP} -set "page=$@.tmp" < main_tpl.mpp > "$@" ; \
	fi
	rm "$@.tmp"

html-pages/img:skin/img
	rm -fr "$@"
	mkdir -p html-pages
	cp -a "$<" "$@"

html-pages/static:skin/static
	rm -fr "$@"
	mkdir -p html-pages
	cp -a "$<" "$@"

html-pages/static/css:skin/static/css
	rm -fr html-pages/static
	make html-pages/static
html-pages/static/img:skin/static/img
	rm -fr html-pages/static
	make html-pages/static

clean:
	rm -fr html-pages *~

