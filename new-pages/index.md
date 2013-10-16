**OCaml** is a general purpose industrial-strength programming language
with an emphasis on expressiveness and safety. Developed for more than
20 years at Inria it benefits from one of the most advanced type systems
and supports functional, imperative and object-oriented styles of
programming. [Read more...](description.html)

Discover
--------

-   [What is OCaml?](description.html)
-   [Try it Online](http://try.ocamlpro.com/)
-   [100 Lines of OCaml](taste.html)
-   [Success Stories](success.html)
-   [Who Is Using It?](companies.html)
-   [Pleac](http://pleac.sourceforge.net/pleac_ocaml/),
    [Rosetta](http://rosettacode.org/wiki/Category:OCaml),
    [langref.org](http://langref.org/ocaml)

Learn
-----

-   [Install](install.html)
-   [Tutorials](tutorials/index.html)
-   [FAQ](faq.html)
-   [Books](books.html)
-   [Videos](videos.html)
-   [Papers](papers.html)

Use
---

-   [Releases](releases/)
-   [Libraries](libraries.html)
-   [Development Tools](dev_tools.html)
-   [User Manual](http://caml.inria.fr/pub/docs/manual-ocaml/)
-   [Cheat Sheets](cheat_sheets.html)
-   [OCaml API Search](http://search.ocaml.jp/)
-   [Forge](http://forge.ocamlcore.org/),
    [GitHub](https://github.com/languages/OCaml),
    [Bitbucket](https://bitbucket.org/repo/all?name=ocaml)

Community
---------

-   [Mailing Lists](mailing_lists.html)
-   [Blogs](planet/)
-   [Meetings](meetings/)
-   IRC ([en](irc://irc.freenode.net/ocaml),
    [fr](irc://irc.freenode.net/ocaml-fr))
-   [Stack
    Overflow](http://stackoverflow.com/questions/tagged?tagnames=ocaml),
    [Reddit](http://www.reddit.com/r/ocaml/)
-   [Commercial Support](support.html)

[![download](img/download-orange-green-arrow.svg)](install.html)

#### OCaml 2013

The OCaml Users and Developers Workshop

Boston MA, United States, Sep 24

[Preliminary program is available](meetings/ocaml/2013/program.html)  

#### Commercial Users of Functional Programming 2013

Boston MA, United States, Sep 22-24

[Submit a Talk](http://cufp.org/2013cfp)  

A taste of OCaml
----------------

    (* Binary tree with leaves carrying an integer. *)
    type tree = Leaf of int | Node of tree * tree

    let rec exists_leaf test tree =
      match tree with
      | Leaf v -> test v
      | Node (left, right) ->
          exists_leaf test left
          || exists_leaf test right

    let has_even_leaf tree =
      exists_leaf (fun n -> n mod 2 = 0) tree

OCaml is a lot more powerful than this simple example shows. Pursue with
[a stronger taste](taste.html)!

News from the community
-----------------------
