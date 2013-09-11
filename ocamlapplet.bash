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

if which -s ocamltohtml
then
    ocamltohtml < $tmpfile.ml > $tmpfile.html
else
    ./ocamltohtml < $tmpfile.ml > $tmpfile.html
fi
echo -n "<script>ml$(id "$1") = '$(./htmlescape < $tmpfile.ml)';</script><span style='position:relative;bottom:-1em;font-size:80%;'><span onclick='alert(\"not yet implemented\")'>[try]</span><span onclick='alert(\"not yet implemented\")'>[copy]</span><span onclick='alert(\"not yet implemented\")'>[github]</span></span>" >> $tmpfile.html

cat $tmpfile.html

rm -f $tmpfile*

