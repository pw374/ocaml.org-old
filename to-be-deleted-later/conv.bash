#!/bin/bash

build_new_md () {
    (
        X=$IFS
        \cd old-pages &&
        \find . -iname \*.html |
        while read l
        do
            mkdir -p ../new-pages/$(dirname $l)
            if \grep -q 'ml:replace="include .*"' $l
            then
                IFS=
                while read i
                do
                    if \grep -q 'ml:replace="include ' <<< "$i"
                    then
                        inc="$(\sed -e 's|.* ml:replace="include \([^ <=>"][^ <=>"]*\)".*|\1|g' <<< "$i")"
                        cat $(dirname "$l")/"$inc" || printf 'l=%s inc=%s\n' "$l" "$inc"
                    else
                        echo "$i"
                    fi
                done < $l | \pandoc -t markdown_strict -o ../new-pages/$(dirname $l)/$(basename $l html)md
            else
                \pandoc $l -t markdown_strict -o ../new-pages/$(dirname $l)/$(basename $l html)md
            fi
        done
        X=$IFS
        )
}

retrieve_meta_data () {
    (
        \cd old-pages && 
        \grep -RIo -e '<title>\(.*\)</title>' . |
        while read l
        do
            local target="../new-pages/$(\sed -e 's/:.*//g' -e 's/.html$/.title/' <<< "$l")"
            local title="$(\sed 's|.*<title>\(.*\)</title>|\1|g' <<< "$l")"
            # printf "newpage=%s title=%s\n" "$newpage" "$title"
            echo "$title" > "$target"
        done
        )
}

make_title () {
    # capitalize the first letter of its first argument, print the rest as is
    # This uses gsed if available, else bash and tr.
    if which -s gsed
    then
        echo -n "$(gsed -e 's/\(.*\)/\u&/g' -e 's/_/ /g' <<< "$1")"
    else
        x="$1"
        c="$(tr '[a-z_]' '[A-Z ]' <<< "${x:0:1}")"
        printf '%s%s' "$c" "${x:1}"
    fi
    shift ; echo " $@"
}

make_tags () {
    ( 
        \cd new-pages
        \find tutorials -iname \*.md | while read l ; do touch "$(\sed -e 's/.md$/.learn/g' <<< "$l")" ; done
    )
}

build_new_html () {
    l="$1"
    mkdir -p "$(\sed 's/new-pages/new-site/g' <<< $(dirname $l))"
    name="$(\sed 's/.md$//' <<< "$l")"
    title="$(if [[ -f $name.title ]] ; then cat "$name.title" ; else make_title "$(basename name)" ; fi)"
    local otheroptions=
    for tag in learn documentation platform packages community bar
    do 
        [[ -f $name.$tag ]] && otheroptions="-set $tag= $otheroptions"
    done
    \pandoc -t html $l -o $l.html
    if \grep -q '<p><em>Table of contents</em></p>' $l.html
    then
        \sed -i.old 's|<p><em>Table of contents</em></p>||g' $l.html
        \rm -f $l.html.old
        X=$IFS
        IFS=
        cat <<EOF
        <div class="span4">
          <nav id="nav-secondary">
            <ul class="nav nav-list">
              <li class="nav-header"><a href="#">Contents</a></li>
EOF
        while read i
        do
            if \grep -q '<h2 id=".*">.*</h2>' <<< "$i"
            then
                if [[ -f h2-o.tmp ]]
                then
                    echo "                </ul>"
                    echo "              </li>"
                    \rm -f h2-o.tmp
                fi
                if [[ -f h2-h.tmp ]] # there is a **former** H2 to be printed!
                then
                    echo "              <li><a href=\"#$(cat h2-h.tmp)\">$(cat h2-i.tmp)</a></li>"
                    \rm -f h2-[hi].tmp
                fi
                \sed -e 's|<h2 id="\(.*\)">\(.*\)</h2>|\1|' <<< "$i" > h2-h.tmp
                \sed -e 's|<h2 id="\(.*\)">\(.*\)</h2>|\2|' <<< "$i" > h2-i.tmp
            elif \grep -q '<h3 id=".*">.*</h3>' <<< "$i"
            then
                \sed -e 's|<h3 id="\(.*\)">\(.*\)</h3>|\1|' <<< "$i" > h3-h.tmp
                \sed -e 's|<h3 id="\(.*\)">\(.*\)</h3>|\2|' <<< "$i" > h3-i.tmp
                if [[ -f h2-h.tmp ]]
                then
                    touch h2-o.tmp
                    cat <<EOF
              <li class="dropdown">
                <a class="dropdown-toggle" href="#$(cat h2-h.tmp)" data-target="#" data-toggle="dropdown">$(cat h2-i.tmp)</a>
                <ul class="dropdown-menu">
EOF
                    \rm -f h2-[hi].tmp
                fi
                echo "                  <li><a href=\"#$(cat h3-h.tmp)\">$(cat h3-i.tmp)</a></li>"
                \rm -f h3-[hi].tmp
            else
                continue
            fi
        done < $l.html
        if [[ -f h2-h.tmp ]] # there is a **former** H2 to be printed!                                                                                                                                  
        then
            echo "              <li><a href=\"#$(cat h2-h.tmp)\">$(cat h2-i.tmp)</a></li>"
            \rm -f h2-[hi].tmp
        fi
        if [[ -f h2-o.tmp ]]
        then
            echo "                </ul>"
            echo "              </li>"
            \rm -f h2-o.tmp
        fi
cat <<EOF
            </ul>
          </nav>
        </div>
EOF
        IFS=$X
    fi > $l.toc
    target="$(\sed 's/new-pages/new-site/g' <<< $name.html)"
    fix=$(for ((i=2; i < $(\sed -e 's|[^/]||g' <<< "$target"| wc -c); i++)) ; do echo -n "/.." ; done)
    \sed -e "s|=\"./|=\".$fix/|g" tpl.mpp |
    mpp $(if [[ -f $l.toc ]] ; then echo -set toc=$l.toc ; fi) -snl -its -set "page=$l.html" -set "title=$title" $otheroptions > "$target"
    \rm -f $l.html
}


build_new_site () {
    mkdir -p new-site
    # build_new_md
    # retrieve_meta_data
    # make_tags
    \cp -r new-pages/img new-site/
    \cp -r new-pages/index-new.html new-site/
    \cp -r new-pages/_site/static/ new-site
    \find new-pages -iname \*.md |
    while read l
    do
        build_new_html "$l"
    done
    ( \cd  new-site && mv index{,-old}.html ; mv index{-new,}.html )
    \cp new-pages/_site/{core,what,100-lines}.html new-site/
}

map () {
    ( \cd new-site || exit
        echo '<ul>'
        \find . -name \*.html | while read l
        do
            echo "<li><a href='$l'>$l</a></li>"
        done
        echo '</ul>'
        ) > map.html
}