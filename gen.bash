#!/bin/bash

if which -s mpp && which -s omd 
then
    true
else
    echo "You don't have mpp and/or omd"
    exit 1
fi

if [[ "$#" == "0" ]]
then
    echo "Usage:"
    echo "$0 md-pages/your-page-to-convert-to-html.md md-pages/a-directory-with-md-files-to-convert"
    exit 1
fi

IFS=
find "$@" -type f -iname '*.md' |
while read i
do
    target="$(sed -e 's/\.md$/.html/' -e 's/^md-pages/html-pages/' <<< "$i")"
    mkdir -p "$(dirname $target)" && make "$target"
done

find "$@" -type f -iname '*.html' |
while read i
do
    target="$(sed -e 's/^md-pages/html-pages/' <<< "$i")"
    mkdir -p "$(dirname $target)"
    cp "$i" "$target"
done

