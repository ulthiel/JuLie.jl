# JuLie.jl

JuLie.jl is an early-stage [Julia](https://julialang.org)/[OSCAR](https://oscar.computeralgebra.de) package with the goal to provide structures and fast algorithms for things around [algebraic Lie theory](https://en.wikipedia.org/wiki/Lie_theory), [representation theory](https://en.wikipedia.org/wiki/Representation_theory), and relevant [combinatorics](https://en.wikipedia.org/wiki/Combinatorics). These fields are huge and this package is still small—I hope it will grow with time. Contributions are necessary and very much welcome!

By Ulrich Thiel ([ulthiel.com/math](https://ulthiel.com/math)) and [contributors](@ref Contributors).

## Using

To install the package, you first need to install [Julia](https://julialang.org). Then after starting Julia, type the following:

```julia-repl
julia> using Pkg
julia> Pkg.add(url="https://github.com/ulthiel/JuLie.jl")
```

Now, you can start using the package as follows:

```julia-repl
julia> using JuLie
julia> partitions(10)
```

You can get help for a function by putting a question mark in front, e.g.

```julia-repl
julia> ?partitions
```

## Motivation

Especially for combinatorics there's a lot already in other computer algebra systems and this justifies the question: why another package? I will give 3 (interwoven) reasons:

1. I want to create a package that covers the mathematics that I especially care about in a way that I think about it. One distant goal is to have all the material available from the book [Introduction to Soergel bimodules](https://www.springer.com/gp/book/9783030488253) with Elias, Makisumi, and Williamson. It will take a lot of time and I don't know if I succeed but it's one motivation.

2. I hope this package will eventually form one pillar of the [OSCAR](https://oscar.computeralgebra.de) project.

3. What really convinced me of Julia as programming language—and thus of the whole enterprise—is its straightforward high-level syntax (like Python) paired with incredible performance (unlike Python). Have a look at the following examples creating the list (not an iterator) of all [partitions](https://en.wikipedia.org/wiki/Partition_(number_theory)) of the integer 90 (there are ~56.6 million) in different computer algebra systems.

In **[Sage](https://www.sagemath.org)** (v9.1):

```
sage: time X=Partitions(90).list()
Wall time: 3min 5s
#Uses 26.665GiB mem, quitting Sage takes quite a bit of time
```

In **[GAP](https://www.gap-system.org)** (v4.11.0):

```
gap> L:=Partitions(90);; time/1000.0;
51.962
#Uses 11.8477 GiB mem, still works fine
```

In **[Magma](http://magma.maths.usyd.edu.au/magma/)** (v2.25-5):

```
> time X:=Partitions(90);
Time: 32.990
//Uses 15.688 GiB mem, Magma unusable from now on
```

And now, in **[Julia](https://julialang.org)** (v1.5.2, my implementation):

```
julia> @time partitions(Int8(90));
5.447290 seconds (56.63 M allocations: 6.239 GiB, 46.77% gc time)
#No problem afterwards
```

I'm cheating here a bit because I'm using 8-bit integers (thus saving memory). But having the possibility to work with special integer types is very useful sometimes. Of course, you can do the same in C—but Julia is a high-level language with a similar simple syntax like Python, so why would anyone still go through such a pain?

## New to Julia?

You can learn all the basics of Julia from the [Julia documentation](https://docs.julialang.org/) but as this is quite a lot to read, I'll mention a few key points.

First of all, you may have noticed that the first time you call a function like ```partitions(10)``` it takes a bit of time to get an answer—but the second time you call it (with any argument) the answer is immediate. This is because Julia uses [just-in-time (JIT) compilation](https://en.wikipedia.org/wiki/Just-in-time_compilation), which means it compiles code at run time just before it is actually needed. This is part of what makes Julia so fast—with the tradeoff that there will be a delay in the first call of a function.

Second, there are two—but likely more—caveats for algebraists in Julia: integers are by default 64-bit integers and division is floating point division:
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

This is of course not what we want. Before we fix this, notice from the example above that every object in Julia is of a certain *type*, e.g. ```Int64``` in case of the number 2. An object of a type called ```MyType``` can be created from input data required by this type by calling ```MyType(...)```, where the dots represent the input data. For example, Julia provides the type ```BigInt``` for big integers (based on the [GMP](https://gmplib.org) library) and we can create big integers as follows:
```julia-repl
julia> a = BigInt(2)
2
julia> typeof(a)
BigInt
julia> a^64
18446744073709551616
```

Much better! Typically, names of types start with an uppercase letter while names of functions start with a lowercase letter. The operator for exact division in Julia is the double slash ```//```:

```julia-repl
julia> x = 6//9
2//3
julia> typeof(x)
Rational{Int64}
```

You see that there is a type ```Rational``` for (exact) rational numbers in Julia. This type is actually a *parametric type* ```Rational{T}``` which means that it refers to rational numbers created from integers of type ```T```—in this case 64-bit integers. I'll leave it to you to find out the type of a division of two big integers.

The advantage of types is that we can write functions with the same name but reacting differently depending on the input types, e.g. the operator ```*``` can be used to multiply integers, polynomials, group elements, etc.

## Basic algebraic structures

Basic algebraic structures are provided by the [AbstractAlgebra](https://nemocas.github.io/AbstractAlgebra.jl/stable/) and [Nemo](https://nemocas.github.io/Nemo.jl/stable/) packages (which are part of OSCAR). Whereas the former provides generic algebraic structures in pure Julia (like a general type of rings and of polynomial rings over a ring), the latter provides very fast arithmetic for special rings (like the integers and polynomial rings over the integers)—often based on the [FLINT](https://www.flintlib.org) library. In JuLie we make use of these packages. Instead of importing the packages as a whole, we just import what we actually need to have maximal control (see the main file ```src/JuLie.jl```). Some of the functions and structures are exported again so that they can be used directly from within JuLie without having to load the packages first, e.g.:

* Big [integers](https://nemocas.github.io/Nemo.jl/stable/integer/) of type ```fmpz``` (with shortcut constructor ```ZZ```) from Nemo. We prefer this to ```BigInt``` because it is what is used in Nemo and is faster.
* Big exact [rationals](https://nemocas.github.io/Nemo.jl/stable/rational/) of type ```fmpq``` (with shortcut ```QQ```) from Nemo.
* [Finite fields](https://nemocas.github.io/Nemo.jl/stable/finitefield/) from Nemo, e.g. ```R, x = FiniteField(7, 3, "x")``` creates the field of characteristic 7 and of degree 3 over the prime field (i.e. having 7³=343 elements) and with primitive element ```x```.
* [Cyclotomic fields](https://nemocas.github.io/Nemo.jl/stable/numberfield/#Nemo.CyclotomicField-Tuple{Int64,%20String}) from Nemo, e.g. ```K,z = CyclotomicField(3, "z")```.
* [Univariant polynomial rings](https://nemocas.github.io/Nemo.jl/dev/polynomial/), e.g. ```R, x = PolynomialRing(ZZ, "x")``` creates the  univariate polynomial ring over the integers with indeterminate ```x```. This is implemented generically in AbstractAlgebra but there are special types for rings optimized in Nemo.
* [Multivariate polynomial rings](https://nemocas.github.io/Nemo.jl/dev/mpolynomial/), e.g. ```R, (x, y) = PolynomialRing(ZZ, ["x", "y"])``` creates the multivariate polynomial ring over the integers with indeterminates ```x``` and ```y```. Again, there are special types for rings optimized in Nemo.
* [Univariate Laurent polynomial rings](https://nemocas.github.io/AbstractAlgebra.jl/stable/laurent_polynomial/), e.g. ```R, x = LaurentPolynomialRing(ZZ, "x")```.
* [Matrices](https://nemocas.github.io/Nemo.jl/stable/matrix/), e.g. ```M = matrix(ZZ, [3 1 2; 2 0 1])```. Again, there are special types for rings optimized in Nemo.
* [Vector spaces](https://nemocas.github.io/AbstractAlgebra.jl/stable/free_module/), e.g. ```VectorSpace(QQ, 2)```, and [free modules](https://nemocas.github.io/AbstractAlgebra.jl/stable/free_module/), e.g. ```FreeModule(ZZ, 3)```.
* [Symmetric groups](https://nemocas.github.io/AbstractAlgebra.jl/stable/perm/), e.g. ```SymmetricGroup(6)```.

Of course, anything from any package can be used as well after loading it in Julia.

## Developing

Contributions are necessary and very much welcome. Here are some guidelines.

### Setting up the repository

Clone this repository to somewhere on your computer:

```
git clone https://github.com/ulthiel/JuLie.jl
```

Enter the directory "JuLie.jl", start Julia, hit the "]" key to enter REPL mode, and then add the package to the registry:

```
dev .
```

Exit the REPL mode by hitting the backspace key. Then you can start using the package as usual with

```
using JuLie
```

Any changes you make to the code now will not be available in the current Julia session—you have to restart it. This is simply the way Julia works but this is annoying when developing. A solution is to load the [Revise](https://timholy.github.io/Revise.jl/v0.6/) package before loading the package.

```
using Pkg
Pkg.add("Revise")
using Revise
using JuLie
```

Now, changes you make in the code are immediately available in the Julia session (except for changes to structures, here you need to restart).

### Programming guidelines

1. Have a look at the file ```src/quantum_analogs.jl``` to see how the stuff works and how I want code to look like.
1. We use *one hard* Tab for indentation.
1. Unicode in the source code and in the documentation is allowed and encouraged. The [LaTex-like abbreviations](https://docs.julialang.org/en/v1/manual/unicode-input/) for unicode characters can be used in, e.g., the [Atom](https://atom.io) editor.
1. To express mathematics in the documentation we use unicode combined with LaTeX. Check out ```src/quantum_analogs.jl``` to see how this looks like.
1. Everything has to be well-documented, algorithms and papers have to be properly referenced. You can build the documentation locally with ```julia make.jl local``` in the directory ```docs```.
1. If your implementation is not more efficient than those in other computer algebra systems then it's not good enough. (Don't take this too seriously, but at least try. I prefer to have a not incredibly fast algorithm than no algorithm at all.)
1. For every function you implement, there has to be a reasonable test in ```test/runtests.jl```. Try to find computed examples in publications or which follow from general theory etc. You can run the complete unit test with ```Pkg.test("JuLie")```.
1. I am collecting all the global imports from other packages in the main file ```JuLie.jl```. If you need more imports, then first put them *not* here but in the file you are working on. When you're finished we can move the imports you need to the main file.
1. Check out the section on basic algebraic structures above. In particular, we use ```fmpz``` for big integers and whatever we can use from AbstractAlgebra and Nemo.
1. Check out the [Julia Documentation](https://docs.julialang.org/en/v1/), especially the [Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/) and the [Performance Guide](https://docs.julialang.org/en/v1/manual/performance-tips/).

## Acknowledgments

This is a contribution to Project-ID 286237555 – TRR 195 – by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation). I also thank my contributors, see below.

## Contributors

* [Max Horn](https://www.quendi.de/en/math) (TU Kaiserslautern, 2020–): Julia
* Tom Schmit (TU Kaiserslautern, 2020–2021): Cartan matrices, Kostka polynomials, Schur polynomials, tableaux
