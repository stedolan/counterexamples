# Mutable matching

TAGS: mutation

Languages with sum types / algebraic datatypes generally include some
form of pattern-matching: a `match`/`case`/`switch` construct that can
inspect values.

The cases in a match statement often contain redundancy, and
compilers optimise these statements by coalescing repeated
subpatterns. For instance, consider this OCaml match:
```ocaml
match x, y with
| 42, 0 -> "foo"
| 42, n -> "bar"
| n, _ -> "baz"
```

The compiled code will first check whether $x = 42$, and if so then
checks whether $y = 0$. The optimisation is that if $y ≠ 0$, the
code skips straight to the `"bar"` outcome, without rechecking whether
$x = 42$.

The assumption here is that $x$ did not change betwen the first
pattern and the second. This assumption can be violated by the
presence of two features: first, the ability to pattern-match on
mutable fields, and second, the ability to run arbitrary code during
pattern matching. (The second feature usually shows up under the name
"guards": additional arbitrary conditions that are checked before the
match succeeds).

If the language contains existential types (e.g. GADTs in OCaml,
abstract type members in Scala), then it is possible for $x$ to not
only change value but change type between two patterns, which leads to
unsoundness. This issue appeared in both OCaml[^ocaml] and
Scala[^scala], which both support mutable matches, arbitrary
conditions in guards, and existential types. Rust[^rust] also had the
issue, with the unsoundness there resulting from disagreement about
lifetime rather than type.

```ocaml
(* Counterexample by Stephen Dolan *)
type app = App : ('x -> unit) option * 'x -> app

let app1 = App (Some print_string, "hello")
let app2 = App (None, 42)

type t = { 
  a : bool; 
  mutable b : app
}

let f = function
| { a = false } -> assert false
| { a = true; b = App (None, _) } -> assert false 
| { a = true; b = App (Some _, _) } as r 
    when (r.b <- app2; false) -> assert false
| { b = App (Some f, x) } ->
   f x

let _ = f { a = true; b = app1 }
```
```scala
// Counterexample by Iulian Dragos
abstract class Bomb {
    type T
    val x: T

    def size(that: T): Int
}

class StringBomb extends Bomb {
    type T = String
    val x = "abc"
    def size(that: String): Int = that.length
}

class IntBomb extends Bomb { 
    type T = Int
    val x = 10

    def size(that: Int) = x + that
}

case class Mean(var bomb: Bomb)

object Main extends App {
    def foo(x: Mean) = x match {
        case Mean(b) => 
            // b is assumed to be a stable identifier, 
            // but it can actually be mutated
			println(b.size({ mutate(); b.x }))
	}

	def mutate() {
	   	m.bomb = new IntBomb
	}

	val m = Mean(new StringBomb)
	foo(m)
}
```
```_rust
// Counterexample by Ariel Ben-Yehuda
fn main() {
    match Some(&4) {
        None => {},
        ref mut foo
            if {
                (|| { let bar = foo; bar.take() })();
                false
            } => {},
        Some(s) => println!("{}", *s)
    }
}
```

This can be fixed by disallowing pattern-matching on mutable fields,
or disallowing mutation during guards. (Either suffices). A trickier
solution chosen by both OCaml and Scala is to write the
pattern-match compiler extremely carefully so that it never loads a
mutable field twice, and so never assumes two possibly-distinct values
to be equal.

[^ocaml]: <https://github.com/ocaml/ocaml/issues/7241> (2016)

[^scala]: <https://github.com/scala/bug/issues/6070> (2012)

[^rust]: <https://github.com/rust-lang/rust/issues/27282> (2015)
