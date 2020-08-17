# Covariant containers

If there is a subtyping between two types, say that every $\n{Car}$ is
a $\n{Vehicle}$, then it is natural to extend this subtyping to
container types, to say that a $\n{List}[\n{Car}]$ is also a
$\n{List}[\n{Vehicle}]$.

However, this is only sound for _immutable_ $\n{List}$ types. If
$\n{List}$ is mutable, then a $\n{List}[\n{Vehicle}]$ is something
into which I can insert a $\n{Bus}$. If every $\n{List}[\n{Car}]$ is
automatically a $\n{List}[\n{Vehicle}]$, then you can end up with
buses in your list of cars.

This problem occurs with arrays in Java:
```java
class Vehicle {}
class Car extends Vehicle {}
class Bus extends Vehicle {}
public class App {
  public static void main(String[] args) {
    Car[] c = { new Car() };
    Vehicle[] v = c;
    v[0] = new Bus(); // crashes with ArrayStoreException
  }
}
```

The solution is to keep track of *variance* (how subtyping of type
parameters affects subtyping of the whole type). There are two
approaches:

  - **Use-site variance** is used in Java (for types other than
    arrays): a `List<Car>` can never be converted to a
    `List<Vehicle>`, but can be converted to a `List<? extends
    Vehicle>`. The elements of a `List<? extends Vehicle>` are known
    to be `Vehicle`s, but an arbitrary `Vehicle` cannot be inserted
    into such a list. Each use of `List` specifies how the parameter
    is allowed to vary.

  - **Declaration-site variance** is used in Scala (although use-site
    variance is also available). This means that the `List` type can
    be defined as `List[+T]` if immutable, making every `List[Car]`
    automatically a `List[Vehicle]`. However, if `List` is mutable, it
    must be defined as `List[T]`, which disables these conversions.

