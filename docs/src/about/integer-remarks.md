# Remarks about integers

Here are two important remarks about integers in JuLie that you need to be aware of.

## Small integer types

As you have seen, the default [integer type](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/) in Julia is 64-bit and we can use large integers of type ```BigInt``` to do exact arithmetic without worries. But having the possibility to use smaller integer types is actually very useful because if you're sure that smaller integer types are sufficient and never overflow in what you intend to do, this will increase performance and consume less memory. In JuLie we have therefore often implemented parametric types depending on an integer type which allow you to do this. For example, for partitions we have a parametric type ```Partition{T}``` where ```T``` is a subtype of ```Integer``` (the union type of all integer types in Julia) and this allows you to do:

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

## fmpz for big integers 

Instead of the Julia type ```BigInt``` for big integers we use the type ```fmpz``` from the [Nemo](https://nemocas.github.io/Nemo.jl/stable/) package (actually from the [FLINT](https://www.flintlib.org) library) because this is what is used in the [OSCAR](https://oscar.computeralgebra.de) system and we want to be compatible with this (see also my [overview](@ref OSCAR)).
