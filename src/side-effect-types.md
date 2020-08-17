# Side-effects in types

Types can be passed around as first-class values in several languages,
either alone or as part of another structure (e.g. first-class modules
in OCaml, abstract type members in Scala). If the language also allows
side-effects, then it is possible to have an expression $T$ that
yields a type, where $T ≠ T$, because $T$ yields two different types
when evaluated twice.

The problem was noticed by Russo[^russo], in his thesis introducing
first-class modules to Standard ML, where he gave a counterexample
showing that the naive approach was unsound. The issue later
reappeared in Scala[^scala].

```sml
(* Counterexample by Claudio Russo *)
module F = functor (X:sig val b:bool end)
  unpack
    if X.b then
      pack struct
        type t = int
        val x = 1
        fun y n = -n
      end
      as sig 
        type t
        val x : t
        val y : t -> t
      end
    else
      pack struct
        type t = bool
        val x = true
        fun y b = if b then false else true
      end
      as sig
        type t
        val x : t
        val y : t -> t
      end
end
as sig
  type t
  val x : t
  val y : t → t
end
module A = F (struct val b = true end)
module B = F (struct val b = false end)
val z = A.y B.x
```
```scala
// Counterexample by Vladimir Reshetnikov
trait A {
  type T
  var v : T
}

object B {
  def f(x : { val y : A }) { x.y.v = x.y.v } 
  
  var a : A = _
  var b : Boolean = false
  def y : A = {
    if(b) {
      a = new A { type T = Int; var v = 1 }
      a
    } else {
      a = new A { type T = String; var v = "" }
      b = true
      a
    }
  }
}

// B.f(B) causes a ClassCastException
```

There are two standard fixes:

  - **Syntactically restrict expressions appearing in types**

    The syntax of type expressions can be limited to constructions
    that cannot possibly contain any mutation. See _paths_ in ML-family
    languages and _stable identifiers_ in Scala.

    This can lead to some surprises, because valid syntax then depends
    on context. For instance, in OCaml, anonymous module parameters
    are possible in module definitions but not type expressions:

    ```ocaml
    module X = struct type t = int end
    module FX = F (X)                           (* ok *)
    type t1 = (F (X)).t                         (* ok *)
    module FX = F (struct type t = int end)     (* ok *)
    type t2 = (F (struct type t = int end)).t   (* error *)
    ```

    (Anonymous module parameters also cause other surprises: see [the
    avoidance problem](avoidance.md))

  - **Restrict effects of expressions appearing in types**

    If the language statically tracks effects, either directly with a
    type-and-effect system or via encoding all effects in an `IO`
    monad, then it is possible to check that only pure expressions are
    used in types.

    There is an additional wrinkle here: some effect systems track
    mutation but allow nontermination to count as "pure". Depending on
    the exact system, allowing a possibly-nonterminating expression
    into the type language may be unsound because of a type-level
    version of the [eventually, nothing](eventually-nothing.md) problem.


[^russo]: Fig 7.12 on p. 270 of [Types For Modules](http://www.dcs.ed.ac.uk/home/cvr/ECS-LFCS-98-389.html), Claudio Russo (1998)

[^scala]: <https://github.com/scala/bug/issues/2079> (2009)




<!-- FIXME

Is this really the eventually, nothing issue?
Seems like the static-tracking variant that I haven't written up yet
  (if there's a type-level entity that's not obviously used,
   its existence might imply some facts that are relied on,
   so you need to evaluate it anyway in case it fails or diverges)


Are these related?
https://issues.scala-lang.org/browse/SI-515
fixed by https://github.com/scala/legacy-svn-scala/commit/febfdeae671ca5f5b80473327058613ddefd67d2
seems specific to singleton types, not sure if it's relevant here

https://issues.scala-lang.org/browse/SI-963
http://www.seas.upenn.edu/~sweirich/types/archive/1999-2003/msg01136.html

How about this?
p312,336 of TAPL2 (first-class module projections, generativity)
-->