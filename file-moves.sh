#!/bin/bash

# This should be expanded into a more complete script but
# for the moment it's just a record of what files I moved where

cd md-pages
mkdir learn docs platform packages community
mv documentation.md docs/index.md
cp platform.md/ platform/index.md
cp platform.md/ community/index.md

git mv tutorials/ learn/tuorials/
