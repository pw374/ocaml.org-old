#!/bin/bash

# This should be expanded into a more complete script but
# for the moment it's just a record of what files I moved where

cd md-pages
mkdir learn docs platform packages community

cp platform.md platform/index.md
cp platform.md community/index.md

git mv tutorials/ learn/tutorials/
git mv platform.md platform/index.md
git mv documentation.md docs/index.md

# mv LEARN content
git mv 100-lines.html learn/100-lines.html
git mv books.md learn/books.md
git mv companies.md learn/companies.md
git mv debug.md learn/tutorials/debug.md
git mv description.md learn/description.md
git mv faq.md learn/faq.md
git mv dev_tools.md learn/tutorials/dev_tools.md
git mv history.* learn/
git mv industrial.md learn/industrial.md
git mv success.* learn/
git mv taste.* learn/
git mv portability.md learn/portability.md
git mv libraries.md learn/libraries.md

# mv DOCS content
git mv cheat_sheets.md docs/cheat_sheets.md
git mv consortium/license.fr.md docs/consortium-license.fr.md
git mv consortium/license.md docs/consortium-license.md
git mv license.* docs/
git mv papers.md docs/papers.md
git mv videos.md docs/videos.md
git mv portability.md learn/portability.md
git mv libraries.md learn/libraries.md
git mv install.* docs/
git mv logos.md docs/logos.md

# mv COMMUNITY content
git mv planet/index.md community/planet.md
git mv support.* community/
git mv mailing_lists.* community/

# mv MISC content
git mv caml-light/ releases/
git rm -r consortium/