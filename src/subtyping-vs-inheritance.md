# Subtyping vs. inheritance

TAGS: subtyping

In an object-oriented language, after writing a class `A` there are
two different ways we might want to extend it:

  - **Subtyping** means writing a class `B` which conforms to `A`'s
      interface, as well as possibly adding some new methods of its
      own. Per Liskov's substitution principle[^liskov], in any
      context where an `A` is expected we can supply a `B` instead.

  - **Inheritance** means writing a class `B` that specialises `A` to
      a particular use, by reusing some of its behaviour and perhaps
      overriding parts.

The two are similar: if the class `B` reuses all of `A`'s
functionality and adds some new methods of its own, then `B` will both
inherit from and be a subtype of `A`.

However, they are not the same. Suppose `B` inherits most of its
behaviour from `A`, but overrides a single method `m`. If `B` is a
specialised version of `A`, its `m` might require a specialised input,
accepting only a specialised version of `A.m`'s input. On the other
hand, if `B` is a subtype of `A`, then in order to conform `A`'s
interface its `m` must accept *all* inputs that `A.m` accepts,
requiring the input of `B.m` to be a *supertype* of that of `A.m`.

Many object-oriented languages conflate inheritance and subtyping as
_subclassing_. Three representative examples are C#, Eiffel and
TypeScript, which differ in how overriden methods in a subclass are
typechecked.  

C# insists that subclasses' methods accept exactly the same types
the overriden method accepts, which is sound but makes some uses of
subtyping and specialisation awkward. Eiffel prefers specialisation,
insisting that subclasses' methods accept subtypes of what the
overriden method accepts, which is unsound[^cook]. TypeScript is ambivalent,
requiring only that subclasses' methods accept either a supertype _or_ a
subtype of what the overriden method accepts, which is also unsound.

The soundness issue is the same one in both TypeScript and Eiffel:
Suppose a method `A.m` may be overriden by `B.m`, where `B.m` accepts
only a subtype of the original type. Since `B` is deemed a subtype of
`A`, a `B` can be used as though it were an `A`, and by invoking its
`B.m` method through `A` an argument which is not of the subtype it
expects can be supplied.
```typescript
interface Base {
    name: string;
}
interface Sub {
    name: string;
    doStuff: () => number;
}

class A {
    go(_ : Base) {}
}
class B extends A {
    go(x : Sub) { x.doStuff(); }
}

let x : Base = { name: "x" };
let b = new B();
let a : A = b;
a.go(x); // crashes
```
```eiffel
-- Counterexample by W. R. Cook
class Base feature
  base (n : Integer) : Integer
    do Result := n * 2 end;
end
---
class Extra inherit Base feature
  extra (n : Integer) : Integer
    do Result := n * n end;
end
---
class P2 feature
  get (arg : Base) : Integer
    do Result := arg.base(1) end
end
---
class C2 inherit P2 redefine get end feature
  get (arg : Extra) : Integer
    do Result := arg.extra(2) end
end
---
  local
    a : Base
    v : P2
    b : C2
    i : Integer
  do
    create a;
    create b;
    v := b;
    i := v.get(a) -- crashes!
  end
```
```ocaml
class type base = object
  method name : string 
end
class type sub = object
  method name : string
  method do_stuff : int
end

class a = object
  method go (_ : base) = ()
end

class b = object (self : < go : sub -> int; .. >)
  (* does not compile *)
  inherit a
  method! go (x : sub) = x#doStuff
end
```
```csharp
class A {
  public void go(Object arg) {}
}
class B : A {
  // does not compile
  public override void go(String arg) {}
}
```

Since version 2.6, TypeScript supports the `strictFunctionTypes`
option[^typescriptStrict], which uses a stricter subtyping check in
some cases. However, the counterexample above is still accepted with
`strictFunctionTypes`.

Theoretically, Eiffel recovers soundness by the "system validity
check", a whole-program dataflow analysis designed to detect
situations like Cook's counterexaxmple (which the Eiffel community
terms "catcalls", for "Changed Availability or Type"). However, this
check is quite tricky, and it appears that no Eiffel compilers have
ever actually implemented it[^cats].

The same issue can crop up with *class methods*, which are methods
that are associated with a class rather than with an instance of that
class. Languages with class methods allow classes to be passed around
as values, dispatching method calls to the appropriate class as
determined at runtime.

When class methods can be overridden in a subclass, this raises the
same subtyping vs. inheritance issue: may the subclass specialise its
argument type, or must it accept a supertype? A soundness issue along
these lines (analagous to the one above) arose in Swift[^swift]:
```swift
// Counterexample by Ben Pious
class C<T> {
    
    let t: T
    
    init(t: T) {
        self.t = t
        type(of: self).f()(self)
    }
    
    class func f<U>() -> (U) -> () where U: C  {
        return { (u: U) in
            print(u.t)
        }
    }
}

class E {
    let g = "Expected to Print"
}

class D: C<E> {
    override class func f<U>() -> (U) -> () where U: E {
        return { (u: E) in
            print(u.g)
        }
    }
}

let d = D(t: E()) // prints random garbage
```



[^liskov]: [A behavioral notion of subtyping](https://dl.acm.org/doi/10.1145/197320.197383),
Barbara Liskov and Jeannette Wing (1994)

[^cook]: [A Proposal for Making Eiffel Type-safe](https://academic.oup.com/comjnl/article/32/4/305/377555), W. R. Cook (1989)

[^typescriptStrict]: <https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-6.html> (2017)

[^cats]: [Catching CATs](http://se.inf.ethz.ch/old/projects/markus_keller/diplom), Markus Keller (2003)

[^swift]: <https://bugs.swift.org/browse/SR-7573> (2018)