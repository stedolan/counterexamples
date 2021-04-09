# Nearly-universal quantification

TAGS: polymorphism, subtyping

This issue is about an interaction between polymorphism and
*constrained type constructors*. These are a feature of several type
systems allowing the definition of a type constructor $T[-]$, where
$T[A]$ is a valid type only for certain $A$.

This feature is different from GADTs (indexed types), which allow the
definition of a type constructor $T[-]$ where $T[A]$ is always a valid
type, but one which is only inhabited for certain $A$.

To explain this distinction, here's a GADT $\n{G}$ and a constrained
type $\n{C}$:
```ocaml
type 'a g = G_int : { name : string } -> int g

type 'a c = { name: string } constraint 'a = int
```
```scala
sealed trait G[T]
case class G_int(i: Int) extends G[Int]

class C[A >: Int <: Int](name : String)
```

The type $\n{C}[A]$ is only legal when $A = \n{Int}$, whereas
$\n{G}[A]$ is always valid, but is an empty type unless $A = \n{Int}$:
```ocaml
type ok = string g

type bad = string c
(* Error: This type string should be an instance of type int *)
```
```scala
type Ok = G[String]

type Bad = C[String]
// Error: type arguments [A] do not conform to
// class C's type parameter bounds [A >: Int <: Int]
```

With constrained types, there are two different ways to interpret a
polymorphic type such as $∀α. \n{C}[α] → \n{String}$:

  1. $∀α.\;\dots$ really means "for all $α$", so the type above is
     invalid since $\n{C}[α]$ is not a valid type for all $α$.

  2. $∀α.\;\dots$ means "for all $α$ for which the right-hand side is
     valid", so the type above is valid, but can only be used with $α
     = \n{Int}$.

Both OCaml and Scala choose option (1):
```ocaml
let poly : 'a . 'a c -> string =
  fun _ -> "hello"
(* Error: The universal type variable 'a cannot be generalized:
          it is bound to int. *)
```
```scala
def poly[A](x: C[A]): String = "hello"
// Error: type arguments [A] do not conform to
// class C's type parameter bounds [A >: Int <: Int]
```

Option (2) requires slightly less annotation by the programmer, but it
can be easy to lose track of the implicit constraints on $α$. Rust
chooses this option, which led to a tricky bug [^rust].

In Rust, the type `&'a T` means a reference to type `T` which is valid
for lifetime `'a`. Lifetimes are ordered by a subtyping relation `'a:
'b` (pronounced "`'a` outlives `'b`"), if the lifetime `'a` contains
all of `'b`. References to references `&'a &'b T` are valid, but only
if `'b: 'a` as the reference's lifetime must not outlive its
contents.

There is also a longest lifetime `'static`, such that `'static: 'a`
for any lifetime `'a`. The bug allows any reference to be converted to
a `'static` reference, breaking soundness guarantees:

```_rust
// Counterexample by Aaron Turon
static UNIT: &'static &'static () = &&();

fn foo<'a, 'b, T>(_: &'a &'b (), v: &'b T) -> &'a T { v }

fn bad<'c, T>(x: &'c T) -> &'static T {
    let f: fn(&'static &'c (), &'c T) -> &'static T = foo;
    f(UNIT, x)
}
```

The issue is that the type of `foo` uses `&'a &'b ()`, which is a
well-formed type only if `'b: 'a`, as a reference cannot outlive its
contents. This constraint `'b: 'a` is relied upon, to allow `v` to be
returned.

Since Rust uses option (2) above, this constraint does not
appear explicitly in the type of `foo`:

```_rust
fn foo<'a, 'b, T> (_: &'a &'b (), v: &'b T) -> &'a T
```

Contravariance allows arguments to be passed with a longer lifetime
than required by the function, allowing `foo` to be used at the
following type, where one argument lifetime has been extended to
`'static`:
```_rust
fn foo<'a, 'b, T> (_: &'a &'static (), v: &'b T) -> &'a T
```

However, the implicit constraint `'b: 'a` has been lost, as validity
now requires only that `'static: 'a`, which is always true. This
allows the type to be instantiated with `'a := 'static`, `'b := 'c`:
```_rust
fn foo<T> (_: &'static &'static (), v: &'c T) -> &'static T
```
which is unsound.

[^rust]: <https://github.com/rust-lang/rust/issues/25860> (2015)
