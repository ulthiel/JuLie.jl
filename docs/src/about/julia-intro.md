# [Introduction to Julia](@id julia-intro)

You can learn all the basics of Julia from the official [documentation](https://docs.julialang.org/) but as this is quite a lot to read, here are a few key points.

First of all, you may have noticed that the first time you call a function like ```partitions(3)``` it takes a bit of time to get an answer—but the second time you call it the answer is immediate. This is because Julia uses [just-in-time (JIT) compilation](https://en.wikipedia.org/wiki/Just-in-time_compilation), which means it compiles code at run time just before it is actually needed. This is part of what makes Julia so fast—with the trade-off that there will be a delay in the first call of a function.

Second, there are two—but likely more—caveats for algebraists in Julia: integers are by default 64-bit integers (on a 64-bit machine) and division is floating point division:

```julia-repl
julia> 2^64
0
julia> typeof(2)
Int64
julia> 6/9
0.6666666666666666
julia> typeof(6/9)
Float64
```

This is of course not what we want. As an algebraist working with Julia you always have to keep in mind:

!!! warning "Warning"
    Julia was designed with applications in numerics in mind.

But we can fix this! First, notice from the example above that every object in Julia is of a certain *type*, e.g. ```Int64``` in case of the number 2. An object of a type called ```MyType``` can be created from input data required by this type by calling ```MyType(...)```, where the dots represent the input data. For example, Julia provides the type ```BigInt``` for big integers (based on the [GMP](https://gmplib.org) library) and we can create big integers as follows:

```julia-repl
julia> a = BigInt(2)
2
julia> typeof(a)
BigInt
julia> a^64
18446744073709551616
```

Much better! There is more to say about integers but we'll come back to this in the [next section](@ref integer-types).

Typically, names of types start with an uppercase letter while names of functions start with a lowercase letter. The operator for exact division in Julia is the double slash ```//```:

```julia-repl
julia> x = 6//9
2//3
julia> typeof(x)
Rational{Int64}
```

You see that there is a type ```Rational``` for (exact) rational numbers in Julia. This type is actually a *parametric type* ```Rational{T}``` which means that it refers to rational numbers created from integers of type ```T```—in this case 64-bit integers. I'll leave it to you to find out the type of a division of two big integers.

You can implement your own types, e.g. here is how I implemented a type for partitions:

```julia
struct Partition{T} <: AbstractVector{T}
    p::Vector{T}
end
```

This means that ```Partition{T}``` is a parametric *subtype* of ```AbstractVector{T}```, the latter being the parametric type of (abstract) one-dimensional arrays. The array is internally stored in the field called ```p``` and this field will be filled by the type constructor:

```julia-repl
julia> P = Partition([6,4,3,1]);
julia> typeof(P)
Partition{Int64}
julia> P.p
4-element Vector{Int64}:
 6
 4
 3
 1
```

As you can see in the partition type example, you can build up a hierarchy—a tree—of types but it is important to note that only the *leaves* of this tree can be instantiated: there is a distinction between *concrete* types (the leaves) and *abstract* types (everything else). If you want to know more about types, you should read the section about [types](https://docs.julialang.org/en/v1/manual/types/) in the Julia documentation.

Functions in Julia are implemented in such a way that one specifies the type of the parameters, there is a function to obtain the conjugate of a partition and this looks like:

```julia
function conjugate(P::Partition{T}) where T<:Integer
    #some code
end
```

Let's try it in the above example:

```julia-repl
julia> conjugate(P)
[4, 3, 3, 2, 1, 1]
```

Beautiful. Now, one of the backbones of Julia is that you can implement a *separate* function with the *same* name ```conjugate``` but acting on a *different* type in a *different* way. This concept is called [multiple dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch). Using types and multiple dispatch one can model mathematical structures roughly to how one abstractly thinks about them and this is another very good reason why Julia is a great choice for modern computer algebra.

!!! warning "Warning"
    Recall that Julia structures form a tree of which only the leaves can be instantiated. Structures in the mathematical world, however, do not form the leaves of a tree, e.g. an algebra over a field is both a vector space and a ring. Therefore, you should not think of types as the ultimate way to go for modeling all sorts of mathematical structures in general. Types should be used to implement structures for which one can implement generic code.

A further important aspect of Julia is that one can [create packages](https://pkgdocs.julialang.org/v1/creating-packages/) (like JuLie) and use everything from any other package as well. You can use JuLie as a template for your own package (see also the additional information in the section on [contributing](@ref Contributing) to learn some basics about developing in Julia).
