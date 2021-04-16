# Scope escape

TAGS: scoping, polymorphism

When both polymorphism (generic functions) and type inference are
present, an issue known as *scope escape* can arise. Suppose that
inside the scope of a variable `f` whose type is being inferred, we
define a polymorphic function of type $∀ α . α → α$. While
type-checking this function, we must ensure that we do not
accidentally infer a type for `f` that mentions the polymorphic
variable $α$, as it was not in scope when `f` was introduced.

Languages that mix type inference and polymorphic definitions must
check that this does not occur:
```haskell
{-# LANGUAGE RankNTypes #-}

idful :: (forall a. a -> a) -> (Int,String)
idful id = (id 5, id "hello")

g f = idful (\x -> let _ = f x in x)
-- GHC error:
--     Couldn't match expected type ‘a -> p0’ with actual type ‘p’
--     because type variable ‘a’ would escape its scope
```
```ocaml
type idful = { id : 'a . 'a -> 'a }
let idful i = i.id 5, i.id "hello"

let g f = idful { id = fun x -> f x; x }
(* Error: This field value has type 'b -> 'b which is less general than
         'a. 'a -> 'a *)
```

Above, the `idful` function requires an argument of type $∀α. α → α$,
but the function it is given leaks its argument to `f`. Naively, we
might infer f takes arguments of type $α$, but this is invalid as $α$
is not in scope outside the argument to `idful`.

The consequences of accidental scope escape are often an internal
error later in the compiler, when it tries to examine the invalid type
that mentions an out-of-scope variable. If scope escape does not cause
the compiler to crash, it is often a soundness issue: inferred types
that escape their scope can cause, for instance, the creation of
[polymorphic references](polymorphic-references.md).

Scope escape bugs have occurred at one time or another in almost every
implementation of polymorphism (especially higher-rank polymorphism),
including Haskell[^haskell], OCaml[^ocaml], Rust[^rust] and
Scala[^scala]:

```haskell
-- Counterexample by Simon Peyton Jones
{-# LANGUAGE MultiParamTypeClasses, TypeFamilies, FlexibleContexts #-} 

module Foo where

type family F a

class C b where {}

foo :: a -> F a
foo x = error "urk"

h :: (b -> ()) -> Int
h = error "urk"

f = h (\x -> let g :: C (F a) => a -> Int
                 g y = length [x, foo y]
             in ())
-- Causes an internal compiler error in Core Lint
```
```ocaml
(* Counterexample by Leo White *)
let (n : 'b -> < m : 'a . ([< `Foo of int] as 'b) -> 'a >) = 
  fun x -> object
    method m : 'x. [< `Foo of 'x] -> 'x = fun x -> assert false
  end;;
(* Type inference gave:
   Error: Values do not match:
          val n : ([< `Foo of int & 'a ] as 'b) -> < m : 'a0. 'b -> 'a0 >
        is not included in
          val n : ([< `Foo of int & 'a ] as 'b) -> < m : 'a0. 'b -> 'a0 >
   Note the & 'a in the argument type.
   That is the univar from 'a . ([< `Foo of int] as 'b) -> 'a.
   (Unknown whether this is a soundness issue) *)
```
```_rust
// Counterexample by @WildCryptoFox
fn f<I>(i: I)
where
    I: IntoIterator,
    I::Item: for<'a> Into<&'a ()>,
{}

fn main() {
    // triggers internal compiler error
    f(&[f()]);
}
```
```scala
// Counterexample by Nada Amin
object Test {
  trait A { a =>
    type X
    val x: a.X
  }
  val a = new A {
    type X = Int
    val x = 1
  }
  def f(arg: A): arg.X = arg.x
  val x = f(a: A)
  // Inferred type of x references out-of-scope 'arg'
  // (Still unknown whether this is a soundness issue)
}
```

[^haskell]: <https://gitlab.haskell.org/ghc/ghc/-/issues/7194> (2012)

[^ocaml]: <https://github.com/ocaml/ocaml/issues/6744> (2015)

[^rust]: <https://github.com/rust-lang/rust/issues/58451> (2019)

[^scala]: <https://github.com/scala/bug/issues/7084> (2013)