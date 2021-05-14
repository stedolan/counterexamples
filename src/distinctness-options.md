# Distinctness III: Options

Many compilers for typed languages accept options which affect type
checking, and to ensure soundness, some care must be taken if mixing
files typechecked with different options.

Options which enable or disable new type system features are
relatively unproblematic, but trouble can occur if options affect
existing types: if two types are considered equal with the option but
are provably distinct without it, then it is unsound to combine two
files compiled with and without the option.


This has caused a soundness bug in Agda[^agda], by mixing code
compiled with the `--cubical` option (which permits multiple proofs of
equality) and the `--with-K` option (which assumes equalities have
unique proofs). Similar bugs arose several times in OCaml, based on
various options that affect type equality: `--rectypes`, which permits
recursive types[^ocamlrec], `--safe-string`, which makes the immutable `string`
and mutable `bytes` type distinct[^ocamlstr], and `--nolabels`, which coarsens
equality of function types with named parameters[^ocamllbl].
```ocaml
(* Counterexample by Gabriel Scherer and Benoît Vaugon *)
(* blah.ml, compiled without -rectypes *)
type ('a, 'b, 'c) eqtest =
  | Refl : ('a, 'a, float) eqtest
  | Diff : ('a, 'b, int) eqtest

let test : type a b . (unit -> a, a, b) eqtest -> b = function
  | Diff -> 42

(* bluh.ml, compiled with -rectypes *)
let () =
  print_float Blah.(test (Refl : (unit -> 'a as 'a, 'a, _) eqtest))
```

These sorts of issues are conspicuously absent from GHC Haskell, which
supports an unusually large number of options that affect
typechecking. A reason for this is that internally, GHC compiles
Haskell with any set of extensions to the same typed intermediate
language, Core. Since the Core language is unaffected by options,
incompatibilities between options would cause one of them to generate
ill-typed Core, which can be detected locally.


[^agda]: <https://github.com/agda/agda/issues/2487#issuecomment-444498567> (2017)

[^ocamlrec]: <https://github.com/ocaml/ocaml/issues/6405> (2014)

[^ocamlstr]: <https://github.com/ocaml/ocaml/issues/7113> (2016)

[^ocamllbl]: <https://github.com/ocaml/ocaml/issues/7432> (2016)

