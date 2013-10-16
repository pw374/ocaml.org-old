# Stream Expressions
## Stream Expressions
Streams are very powerful and concise once the necessary tools (stream
builders, combinators, and other utilities) are in place. However, the
code behind these tools can be a chore to write, at times resembling
state machines more than elegant functional expressions. The Camlp4
preprocessor adds syntax support for stream and stream parser
expressions, raising the level of abstraction a bit higher and
simplifying many common stream-oriented tasks.

## Interactive Use
To enable stream expression support in the toplevel, you can type the
following:

```tryocaml
#load "dynlink.cma";;
#load "camlp4o.cma";;
```
Or, if you are using findlib:

```tryocaml
#use "topfind";;
#camlp4o;;
```
## Stream Literals
Stream expressions are enclosed by "[\<" and "\>]" brackets, and using
them is a lot like using lists. The simplest stream possible is the
empty stream:

```tryocaml
[< >]
```
Literal values in stream expressions are prefixied by single-quotes:

```tryocaml
let more_numbers = [< '1; '2; '(1 + 2) >]  (* Equivalent to Stream.of_list [1; 2; 3] *)
```
This is to distinguish them from streams, which are automatically
concatenated:

```tryocaml
[< '1; '2; more_numbers; '99 >]
```
In the above example, the stream will produce the integers 1 and 2,
followed by all of the values generated by the `more_numbers` stream,
and once `more_numbers` as been exhausted, it will produce the integer
99.

## Recursive Definition
Streams can be defined with recursive functions, providing a
straightforward and familiar mechanism to produce infinite sequences.
The following defines an never-ending stream of 1s:

```tryocaml
  let ones =
    let rec aux () =
      [< '1; aux () >] in
    aux ()
```
Note the auxiliary function, `aux`, which is called recursively to form
a loop. This is necessarily different from infinite lists, which can be
defined with "let rec" without a helper function:

```tryocaml
let rec ones = 1 :: ones
```
The stream expression syntax is not able to interpret recursive values
like this, and attempts to do this will result in a syntax error:

```tryocaml
let rec ones = [< '1; ones >];;
```
This is only a minor inconvenience, since most streams will be built
from one or more parameters. For example, here is the `const_stream`
from the [Streams](streams.html "Streams") chapter, redefined using
stream expression syntax:

```tryocaml
let rec const_stream k = [< 'k; const_stream k >]
```
Similarly, this simple one-liner is all it takes to produce a counter:

```tryocaml
let rec count_stream i = [< 'i; count_stream (i + 1) >]
```
Below is a slightly more complicated example, using two stream
expressions to define a Fibonacci sequence:

```tryocaml
  let fib =
    let rec aux a b =
      [< '(a + b); aux b (a + b) >] in
    [< '0; '1; aux 0 1 >];;
  Stream.npeek 10 fib;;
```
## Example: Directory walker
As a more practical example, we can define a recursive directory walker
that avoids loading the entire directory tree into memory:

```tryocaml
let rec walk dir =
  let items =
    try
      Array.map
        (fun fn ->
           let path = Filename.concat dir fn in
           try
             if Sys.is_directory path
             then `Dir path
             else `File path
           with e -> `Error (path, e))
        (Sys.readdir dir)
    with e -> [| `Error (dir, e) |] in
  Array.fold_right
    (fun item rest ->
       match item with
       | `Dir path -> [< 'item; walk path; rest >]
       | _ -> [< 'item; rest >])
    items
    [< >]
```
This function works by first assembling an array of paths for the
specified base directory. Each path is wrapped in a variant type that
keeps track of which path is a file and which is a directory. The array
is then folded into a stream, expanding each subdirectory by recursively
calling `walk` again. Errors are included in the variant so that
exceptions can be handled or ignored as needed.

The expanding of subdirectories

```tryocaml
[< 'item; walk path; rest >]
```
illustrates a convenient feature of stream expressions: any number of
sub-streams can appear in any order, and they will be lazily evaluated
as needed. `walk path` and `rest` both evaluate to streams that are
concatenated with `item` at the front. The results are flattened into a
single stream, just as if we had used something like `stream_concat`,
defined in the [Streams](streams.html "Streams") chapter.

With little effort, we can now print the names of all the directories
and files underneath "/var/log":

```tryocaml
let () =
  Stream.iter
    (function
     | `Dir path ->
         Printf.printf "dir: %s%!\n" path
     | `File path ->
         Printf.printf "file: %s%!\n" path
     | `Error (path, e) ->
         Printf.printf "error: %s (%s)%!\n" path
           (Printexc.to_string e))
    (walk "/var/log")

```