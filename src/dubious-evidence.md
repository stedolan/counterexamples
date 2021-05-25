# Dubious evidence

TAGS: empty-types, equality

While the `Empty` type of the previous counterexample has no values at
all, there are types whose emptiness depends on their parameters. The
canonical example is the equality type, expressible as a GADT in
Haskell or OCaml or as an inductive family in Coq or Agda (among
others):
```ocaml
type (_, _) eq =
  Refl : ('a, 'a) eq
```
```haskell
data Eq a b where
  Refl :: Eq a a
```
```coq
Inductive eq {S : Set} : S -> S -> Prop :=
  Refl a : eq a a.
```
```agda
data Eq {S : Set} : S -> S -> Set where
  refl : (a : S) -> Eq a a
```

The type `(a, b) eq` witnesses equality: it is nonempty if `a` and `b`
are the same type, and empty if they are distinct. Values of type `(a,
b) eq` constitute evidence that `a` and `b` are in fact the same, and
can be used e.g. to turn an `a` into a `b`.

For an arbitrary type `a`, we have no way of making an `(int, a) eq`:
for all we know `a` might be `string`. The only way to construct a
value of the `eq` type is using `Refl`, which demands the parameters
be equal.

In a pure, total language, the existence of an expression of type `(a,
b) eq` is enough to conclude `a` and `b` are equal. But in a less pure
language, where evaluation might fail or loop, the mere existence of
an expression with the right type is not evidence enough: we need to
actually run it, to see that it does in fact yield `Refl`. Several
type systems have had soundness bugs where evidence of this sort is
trusted without being fully evaluated:

  - **Null evidence**

    In languages with `null`, types like `eq` contain `null`, and
    unlike `Refl`, `null` implies nothing about its type
    parameters. So, before making use of any evidence we need to
    verify that the evidence isn't `null`.

    The lack of such verification caused a soundness issue in Java and
    Scala[^amintate] (using a type that provides evidence for
    subtyping, rather than equality):
    ```java
    // Counterexample by Nada Amin and Ross Tate
    class Unsound {
      static class Constrain<A, B extends A> {}
      static class Bind<A> {
        <B extends A>
        A upcast(Constrain<A,B> constrain, B b) {
          return b;
        }
      }
      static <T,U> U coerce(T t) {
        Constrain<U,? super T> constrain = null;
        Bind<U> bind = new Bind<U>();
        return bind.upcast(constrain, t);
      }
      public static void main(String[] args) {
        String zero = Unsound.<Integer,String>coerce(0);
      }
    }
    ```
    ```scala
    // Counterexample by Nada Amin and Ross Tate
    object unsoundMini {
      trait A { type L >: Any}
      def upcast(a: A, x: Any): a.L = x
      val p: A { type L <: Nothing } = null
      def coerce(x: Any): Nothing = upcast(p, x)
      coerce("Uh oh!")
    }
    ```

  - **Self-justifying evidence**

    Evidence `p : (int, a) eq` can be used to construct more evidence
    that `int` and `a` are equal, by seeing that `p` is `Refl`,
    therefore learning that `int` and `a` are equal, and using this
    information to justify `Refl : (int, a) eq`.

    OCaml[^ocamlbug] had a soundness issue in which it allowed this sort of
    reasoning in a recursive definition of `p`, allowing `p` to be
    used as evidence for itself:

    ```ocaml
    (* Counterexample by Stephen Dolan *)
    type (_,_) eq = Refl : ('a, 'a) eq
    let cast (type a) (type b) (Refl : (a, b) eq) (x : a) = (x : b)
    
    let is_int (type a) =
      let rec (p : (int, a) eq) = match p with Refl -> Refl in
      p
    
    let bang =
      (* segfaults *)
      print_string (cast (is_int : (int, string) eq) 42)
    ```

  - **Out-of-order evidence**

    When nontermination is possible, it is important to ensure that
    the order in which evidence is used matches the evaluation
    order. Otherwise, it is possible to write an expression that does
    not terminate, but make use of it before it runs. Such forward references
    caused a soundness issue in Scala[^scalafwd]:

    ```scala
    // Counterexample by Paolo G. Giarrusso
    new {
      val a: String = (((1: Any): b.A): Nothing): String
      def loop(): Nothing = loop()
      val b: { type A >: Any <: Nothing } = loop()
    }
    ```

  - **Time-travelling evidence**

    *Staged metaprogramming* allows a program to manipulate program
     fragments, gluing together an output program from quoted
     fragments of code. However, it is unsound to allow evidence
     computed in the future by the generated output program to justify
     computations now. This caused a soundness bug in Scala's
     implementation of staged metaprogramming[^scalastage] and in
     BER MetaOCaml[^metaocamlbug]:

     ```scala
     // Counterexample by Lionel Parreaux
     import scala.quoted.staging._
     
     given Toolbox = Toolbox.make(getClass.getClassLoader)
     trait T { type A >: Any <: Nothing }
     
     withQuoteContext { '{ (x: T) => ${ 42: x.A } } }
     // crashes with java.lang.ClassCastException
     ```
     ```ocaml
     (* Counterexample by Jeremy Yallop *)
     type _ t = T : string t

     let f : type a. a t option code -> a -> unit code =
       fun c x -> .< match .~c with
       | None -> ()
       | Some T -> .~(print_endline x; .<()>.) >.

     let _ = f .< None >. 0
     ```

[^amintate]: [Java and Scala’s Type Systems are Unsound](http://io.livecode.ch/learn/namin/unsound/scala) (OOPSLA '16)
Nada Amin and Ross Tate (2016)

[^ocamlbug]: <https://github.com/ocaml/ocaml/issues/7215> (2016)

[^scalafwd]: <https://github.com/lampepfl/dotty/issues/5854> (2019)

[^scalastage]: <https://github.com/lampepfl/dotty/issues/9353> (2020)

[^metaocamlbug]: <https://github.com/metaocaml/ber-metaocaml/blob/ber-n111/ber-metaocaml-111/test/tgadt.ml> (2016)
