# [Integer types](@id integer-types)

There are various [integer types](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/) in Julia. On the one hand there are integer types with a fixed number of bits ranging from 8-bit integers ```Int8``` to 128-bit integers ```Int128```. The default integer type ```Int``` will be ```Int64``` (on a 64-bit machine). Moreover, there is ```BigInt``` for arbitrary precision integers. Finally, there is a union type ```Integer``` encompassing all the various integer types.

We are not done yet with the integer types. The [Nemo](https://nemocas.github.io/Nemo.jl/stable/) package (which is part of the [OSCAR](https://oscar.computeralgebra.de) system) introduces another arbitrary precision integer type ```fmpz``` (with shortcut constructor ```ZZ```) from the [FLINT](https://www.flintlib.org) library:

```julia
julia> ZZ(2)^64
18446744073709551616

julia> typeof(ZZ(2))
Nemo.fmpz
```

!!! warning "Warning"
    In JuLie we will use ```fmpz``` instead of ```BigInt```.

There are various reasons why Nemo/OSCAR (and thus JuLie) prefers ```fmpz```: this type is more efficient as it scales between machine integers and big integers; it is better to "own" the integer type when doing exact computer algebra because some Julia functions don't really do what we expect as algebraists (for example the determinant function ```det``` from the [LinearAlgebra](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/) package returns a ```float``` for a matrix consisting of ```Int64``` integers); the *ring* ℤ itself is implemented as a structure in Nemo/OSCAR and the  ```fmpz``` integers really live in this ring, which reflects the mathematics more accurately:

```julia
julia> parent(ZZ(2))
Integer Ring
```

Some mathematical functions in Julia/OSCAR working on integers will return an integer of the same type as they received but this is not completely consistent:

```julia
julia> typeof(factorial(10)) #factorial(21) will cause an overflow error
Int64

julia> typeof(factorial(Int8(10)))
Int64 #Not Int8!

julia> typeof(factorial(ZZ(10))) #factorial(ZZ(21)) no problem
Nemo.fmpz
```

!!! warning "Warning"
    Always be aware of (and careful with) the integer types you pass to a function and that you get back.

As an algebraist, you would be one the safe side by always using ```fmpz```. But having the possibility to use smaller integer types is actually very useful because if you're sure that smaller integer types are sufficient and never overflow in what you intend to do, this will increase performance and consume less memory. In JuLie we have therefore often implemented parametric types depending on an integer type which allow you to do this. For example, for partitions we have a parametric type ```Partition{T}``` where ```T``` is a subtype of ```Integer``` (the union type of all integer types in Julia) and this allows you to do:

```julia-repl
julia> P=Partition(Int8[2,1])
Int8[2, 1]
```

We have created the partition (2,1) of 3 using 8-bit integers. Compare this to constructing the partition with the default integer type:

```julia-repl
julia> P=Partition([2,1])
[2, 1]
```

It's basically the same thing but the former will consume less memory which will be important when dealing with millions of partitions. But you need to be careful when doing arithmetic with the components of a partition because this may overflow—and if it does there will be no warning by Julia!

Now, functions dealing with partitions can work with smaller integer types as well:

```julia-repl
julia> partitions(Int8(3))
3-element Vector{Partition{Int8}}:
 Int8[3]
 Int8[2, 1]
 Int8[1, 1, 1]
```

compared to

```julia-repl
julia> partitions(3)
3-element Vector{Partition{Int64}}:
 [3]
 [2, 1]
 [1, 1, 1]
```

Let's summarize:

!!! warning "Advice and warning"
    Use smaller integer types to your advantage but be careful to not cause overflows in your computations.

