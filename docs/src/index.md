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

1. I want to create a package that covers the mathematics that I care about in a way that I think about it. One distant goal is to have all the material available from my book [Introduction to Soergel bimodules](https://www.springer.com/gp/book/9783030488253) with Elias, Makisumi, and Williamson. It will take a lot of time and I don't know if I succeed but it's one motivation.

2. I hope this package will eventually form one pillar of the [OSCAR](https://oscar.computeralgebra.de) project.

3. What really convinced me of Julia as programming language—and thus of all the whole enterprise—is its straightforward high-level syntax (like Python) paired with incredible performance (unlike Pyhton). Have a look at the following examples creating the list (not an iterator) of all [partitions](https://en.wikipedia.org/wiki/Partition_(number_theory)) of the integer 90 (there are ~56.6 million) in different computer algebra systems.

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
//Uses 15.688 GiB mem, Magma UNUSABLE from now on!!
```

And now, in **[Julia](https://julialang.org)** (v1.5.2, my implementation):

```
julia> @time partitions(Int8(90));
5.447290 seconds (56.63 M allocations: 6.239 GiB, 46.77% gc time)
#No problem afterwards
```

I'm cheating here a bit because I'm using 8-bit integers (thus saving memory). But we can also use bigger integers and the Julia implementation is still more efficient:

```
julia> @time partitions(Int64(90)); #this time with 64-bit integers
16.481893 seconds (56.63 M allocations: 13.570 GiB, 57.15% gc time)
#No problem
```

Having the possibility to work with special integer types is very useful sometimes. Of course, you can do the same in C—but Julia is a high-level language with a similar simple syntax like Python, so why would anyone still go through such a pain?

The [Nemo](http://nemocas.github.io/Nemo.jl/latest/) package (part of OSCAR) provides incredibly fast arithmetic in various rings like integers, algebraic number fields, polynomial rings etc. that will be used here as well.

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

1. Have a look at the file ```src/partitions.jl``` to see how the stuff works and how I want code to look like.
2. Check out the [Julia Documentation](https://docs.julialang.org/en/v1/), especially the [Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/) and the [Performance Guide](https://docs.julialang.org/en/v1/manual/performance-tips/).
3. Everything has to be well-documented, algorithms and papers have to be properly referenced. You can build the documentation locally with ```julia make.jl local``` in the directory ```doc```. 
4. If your implementation is not more efficient than those in other computer algebra systems then it's not good enough. (Don't take this too seriously, but at least try. I prefer to have a not incredibly fast algorithm than no algorithm at all.)
5. For every function you implement, there has to be a reasonable test in ```test/runtests.jl```. You can run the complete unit test with ```Pkg.test("JuLie")```.
6. For large number arithmetic we use [Nemo](https://github.com/Nemocas/Nemo.jl) (type fmpz with constructor ZZ for integers, type fmpq with constructor QQ for rationals, etc.). See the file ```src/enum_func.jl``` for examples. For more general rings (polynomial rings, laurent polynomial rings, etc.) we use [AbstractAlgebra](https://github.com/Nemocas/AbstractAlgebra.jl), see ```src/quantum_numbers.jl``` for examples. This is all part of the [OSCAR](https://oscar.computeralgebra.de) system.


## Contributors

* Max Horn (TU Kaiserslautern, 2021–)
* Tom Schmit (TU Kaiserslautern, 2020–)
