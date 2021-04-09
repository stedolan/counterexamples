# Selfishness

TAGS: subtyping

Most statically typed object-oriented languages allow a group of
related methods to be specified together as an *interface* (or
"trait", "protocol", etc.). *Self types* are a feature that allows the
types in such an interface to refer to the type implementing that
interface.

Using self types as method arguments allows precise typechecking of
*binary methods*[^binary] such as `equals`, where `x.equals(y)`
requires a `y` of the same type as `x`. The lack of such types in
e.g. Java means that the `Object.equals` method must usually include a
cast that can fail at runtime, as its type allows any other object to
be passed.

Using self types as returns allows precise typechecking of methods
that return `this`, or methods that copy the receiving object.

However, the presence of self types breaks some properties of the type
system, and unsoundness arises if other parts of the system rely on
them.

  - Argument self types break the property that, if a class `C` has a
    subclass `D` and both implement an interface `P`, then a `D` can
    be used anywhere a `C` is expected. The issue is that `P` may
    include a method that accepts a self type, and this method in `D`
    works on a narrower class of inputs than the corresponding method
    in `C`. (See [Subtyping vs. inheritance](subtyping-vs-inheritance.md))

    ```ocaml
    class c (name : string) =
      object (self : 'self)
        method name = name
        method equals (x : 'self) =
          (name = x#name)
      end
    
    class d (name : string) (size : int) =
      object
        inherit c name as super
        method size = size
        method equals (x : 'self) =
          (super#equals x && size = x#size)
      end
    
    let sub (x : d) = (x :> c)
    (* OCaml correctly rejects this coercion:
       despite inheriting from it, d is not a subtype of c *)
    ```


  - Returned self types break the property that, if a class `C`
    implements an interface `P`, and subclass `D` inherits all of its
    behaviour from `C`, then `D` also implements `P`.

    The issue is that `P` may include a method that returns
    `Self`, which `C` implements by returning a new `C`. When this
    method is inherited by `D` it still returns `C`, even though `P`
    now requires that it return `D`. This led to a soundness issue in
    Swift[^swift], and a related issue in Rust[^rust]:

    ```swift
    // Counterexample by Hamish Knight
    protocol P {
      associatedtype X where X == Self
      func foo() -> X
    }
    
    class C : P {
      typealias X = C
      func foo() -> X {
        return C()
      }
    }
    class D : C {
        var name = "D"
    }
    
    func foo<T : P>(_ x: inout T) {
      x = x.foo()
    }
    
    var d = D()
    foo(&d)
    print(d.name) // crashes
    ```
    ```_rust
    // Counterexample by Niko Matsakis
    trait Make {
        fn make() -> Self;
    }
    
    impl Make for *const uint {
        fn make() -> *const uint {
            ptr::null()
        }
    }
    
    fn maker<M:Make>() -> M {
        Make::make()
    }
    
    fn main() {
        let a: *uint = maker::<*uint>();
        // we have "produced" a *uint even though there is no
        // function in this program that returns one.
    }
    ```

An alternative to self types is to use generic interfaces: instead of
an interface $\n{Equals}$ with an `equals` method accepting a self
type, one can use a generic interface $\n{Equals}[A]$ whose `equals`
method accepts an $A$, and then write classes $\n{C}$ that implement
$\n{Equals}[\n{C}]$. This is the approach taken by C#'s
`IEquatable<T>` and Java's `Comparable<T>`.



[^binary]: [On Binary Methods](https://core.ac.uk/download/pdf/38891811.pdf), Kim Bruce, Luca Cardelli, Giuseppe
Castagna, The Hopkins Objects Group, Gary T. Leavens, and Benjamin
Pierce (1995)

[^swift]: <https://bugs.swift.org/browse/SR-10713> (2019)

[^rust]: <https://github.com/rust-lang/rust/issues/5781> (2013)