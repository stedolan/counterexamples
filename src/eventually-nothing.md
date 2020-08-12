# Eventually, nothing

Many type systems allow an empty type, which has no values:

```_rust
enum Empty {}
```
```ocaml
type empty = |
```
```haskell
data Empty
```

The eliminator for the empty type allows it to be turned into a value
of any other type, by handling each of the zero possible cases:
```_rust
fn elim<T>(v : Empty) -> T { match v {} }
```
```ocaml
let elim (x : empty) = match x with _ -> .
```
```haskell
{-# LANGUAGE EmptyCase #-}
elim :: Empty -> a
elim x = case x of {}
```

The `elim` function claims to be able to produce a valid value of an
arbitrary type, but will never need to actually do this since its
input cannot be supplied.

In non-total languages is it possible to write an expression
of type `empty`, by writing one that does not evaluate to a value but
instead fails or diverges:
```_rust
fn bottom() -> Empty { loop {} }
```
```ocaml
let bottom : empty =
  let rec loop () = loop () in loop ()
```
```haskell
bottom :: Empty
bottom = bottom
```

This interacts badly with an optimisation present in C compilers:
according to the C standard, compilers are allowed to assume that the
program contains no infinite loops without side-effects. (The point of
this odd assumption is to allow the compiler to delete a loop that
computes a value which is not used, without needing to first prove
that the loop terminates).

So, infinite loops may be deleted when compiling using a backend
designed for C and C++ (e.g. LLVM), allowing "values" of the empty
type to be constructed:
```_rust
let s : &str = elim(bottom());
println!("string: {}", s);
```
```ocaml
(* The OCaml compiler does not delete empty loops, so
   computing bottom correctly diverges rather than crashing *)
print_endline (elim bottom)
```
```haskell
-- GHC does not delete empty loops, so
-- this correctly diverges rather than crashing
putStrLn (elim bottom)
```
When optimisations are turned on, this program crashes in Rust[^rustbug].

[^rustbug]: <https://github.com/rust-lang/rust/issues/28728> (2015)

<!-- FIXME: Make this segfault using Result<string, Empty> ?
  Cite C standard section?
  
-->