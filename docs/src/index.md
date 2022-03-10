# JuLie

JuLie is an early-stage package for the programming language [Julia](https://julialang.org) with the goal of providing mathematically sound structures and fast algorithms for things around representation theory, especially algebraic Lie theory and accompanying combinatorics. These fields are huge and this package is still small—I hope it will grow with time. [Contributions](@ref Contributing) are necessary and very much welcome!

By [Ulrich Thiel](https://ulthiel.com/math) (University of Kaiserslautern) and [contributors](@ref Contributors).

## Installation

You first need to install [Julia](https://julialang.org) (this works on any operating system). Then after starting Julia, type the following to install this package:

```julia-repl
julia> using Pkg
julia> Pkg.add(url="https://github.com/ulthiel/JuLie.jl")
```

Now, you can start using JuLie by typing:

```julia-repl
julia> using JuLie
```

Here's an example:

```julia-repl
julia> partitions(3)
3-element Vector{Partition{Int64}}:
 [3]
 [2, 1]
 [1, 1, 1]
julia> @time partitions(Int8(90)); #One goal of JuLie is being fast :-)
  5.844981 seconds (56.63 M allocations: 6.239 GiB, 19.75% gc time)
```

## Acknowledgments

This work is a contribution to the [SFB-TRR 195](https://www.computeralgebra.de/sfb/) 'Symbolic Tools in Mathematics and their Application' of the German Research Foundation (DFG). I thank everyone who contributed (see below). The logo shows the root system of type G₂ and is taken from [Wikipedia](https://commons.wikimedia.org/wiki/File:Root_system_G2.svg).

## Contributors

* [Max Horn](https://www.quendi.de/en/math) (TU Kaiserslautern, 2020): Julia generalities
* Tom Schmit (TU Kaiserslautern, 2020–2021): Cartan matrices, Coxeter groups, Documenter.jl and GitHub integration, Kostka polynomials, Schur polynomials, Tableaux
* Elisa Thiel (2020): De-gotoing old ALGOL code
