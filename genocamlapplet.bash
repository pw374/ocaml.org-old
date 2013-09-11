#!/bin/bash

function id () {
    if [[ "$1" != "" ]]
    then
        echo $1
    else
        hash < $tmpfile.ml
    fi
}

tmpfile=$(date +tmp%Y%m%d%H%M%S%N)_$RANDOM$RANDOM$RANDOM

cat > $tmpfile.ml

function hash() {
    cat | (md5 || md5sum) | sed -e 's| ./*||g'
}

echo -n "<script>ml$(id "$1") = '$(./htmlescape < $tmpfile.ml)';</script>" > $tmpfile.html

if which -s ocamltohtml
then
    ocamltohtml < $tmpfile.ml >> $tmpfile.html
else
    ./ocamltohtml < $tmpfile.ml >> $tmpfile.html
fi

cat $tmpfile.html

rm -f $tmpfile*

