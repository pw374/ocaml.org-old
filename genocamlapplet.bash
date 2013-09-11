#!/bin/bash

tmpfile=$(date +tmp%Y%m%d%H%M%S%N)_$RANDOM$RANDOM$RANDOM

cat > $tmpfile.ml

function hash() {
    cat | (md5 || md5sum) | sed -e 's| ./*||g'
}

echo -n "<script>ml$(hash < $tmpfile.ml) = '$(./htmlescape < $tmpfile.ml)';</script>" > $tmpfile.html

if which -s ocamltohtml
then
    ocamltohtml < $tmpfile.ml >> $tmpfile.html
else
    ./ocamltohtml < $tmpfile.ml >> $tmpfile.html
fi

cat $tmpfile.html

rm -f $tmpfile*

