OCAML.ORG PROJECT
=================
This is the source code implementing a new website for the OCaml
community. Information here is relevant only to developers and content
contributors. End-users of the website should simply visit the
website, which is hosted at http://ocaml.org.


DEPENDENCIES
============
Building the html pages requires:

* ocaml
* [oasis](http://forge.ocamlcore.org/projects/oasis/)
* [weberizer](https://github.com/Chris00/weberizer)
* [Ocamlnet](http://projects.camlcity.org/projects/ocamlnet.html)
* [OCamlRSS](http://zoggy.github.com/ocamlrss/)

Weberizer is Christophe Troestler's templating tool. It allows us to
easily provide a consistent design to multiple pages. You will only
need to understand this tool if you are contributing design
changes. Content contributors can focus on the pure html source within
src/html/.


BUILD
=====
Currently the site consists only of static html pages, and so can be
built and run entirely on a local machine without dependencies on
external file or database servers. Simply run:

    make

This will generate a new folder 'www' that contains the full website.


PUBLISH
=======
Changes can be published by running:

    make publish

Of course, this is only allowed by the project administrators that
have write permission to the production server.


CONTACTS
========
You can reach the development team by posting to the [infrastructure
mailing list](http://lists.ocaml.org/listinfo/infrastructure). Please
note the older ocamlweb-devel@lists.forge.ocamlcore.org has been
retired and is no longer in use.

To begin contributing, visit the [master
repo](https://github.com/ocaml/ocaml.org) on github, click the "Fork"
button, make changes to your copy, and submit pull requests. It's that
easy!

Structure of the site (redesign)
=====================

- `md-pages` is the directory where "MPP" Markdown files are.
  - Those are meant to be preprocessed with MPP to produce "pure" Markdown files. 
- `html-pages` is a directory that is *generated*. You're not supposed to put anything important inside because it may get deleted at anytime. (And it's not on Git, of course.) However it's *the* directory that contains the final ocaml.org website.
- `gen.bash` is the script that accepts (as arguments) `.md` files or directories that are `md-pages` or inside of it.
- `Makefile` is used by `gen.bash` to actually generate each `.html` page inside `html-pages`.
- `main_tpl.mpp` is the main template for generating the `.html` pages.
- ***undocumented files are either waiting to be documented, or deleted.***

-------------------------------
"MPP Markdown" means "Markdown that needs to be processed with MPP
before being real Markdown".

