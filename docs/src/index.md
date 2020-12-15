# JuLie.jl
An early-stage [Julia](https://julialang.org)/[OSCAR](https://oscar.computeralgebra.de) package for things around algebraic Lie theory, representation theory, and relevant combinatorics. Contributions are very much welcome!

By Ulrich Thiel ([ulthiel.com/math](https://ulthiel.com/math)) and contributors.

```@meta
CurrentModule = JuLie
```

## Using

To install the package, do the following In Julia:

```
using Pkg
Pkg.add(url="https://github.com/ulthiel/JuLie.jl")
```

Then you can start using the package as follows:

```
using JuLie
partitions(10)
```

You can get a list of exported functions using

```
names(JuLie)
```

You can get help for a function by putting a question mark in front, e.g.

```
?partitions
```


## Partitions

```@docs
Partition
getelement
dominates
conjugate
partitions
ascending_partitions
```

### Multipartitions

```@docs
Multipartition
multipartitions
```

### Multiset_partitions

A **Multiset_partition** is a Multipartition ``λ^{(1)},...,λ^{(r)}`` where each ``\lambda^{(i)}`` is a non-empty partition.``\\``
Furthermore the ordering of the Partitions ``\lambda^{(i)}`` is not important, i.e. ``\lambda^{(1)},...,\lambda^{(r)}``=``\lambda^{(\sigma(1))},...,\lambda^{(\sigma(r))}`` ``\\``
**Note:** This equality-relation is not implemented in this Module.

```@docs
multiset_partitions
partition_to_partcount
partcount_to_partition
```

## Tableaux

```@docs
Tableau
shape
weight
reading_word
hook_length
hook_length_formula
schensted
bump!
```

### semistandard Tableaux

A **semistandard tableaux** is a tableaux where the values are non decreasing in each row, and strictly increasing in each column.

```@docs
semistandard_tableaux
is_semistandard
```

### standard Tableaux

A **standard tableaux** is a tableaux where the values are strictly increasing in each row and column. A standard tableaux also requires each Integer from 1 to the amount of boxes to occur exactly once.

```@docs
standard_tableaux
is_standard
```

## Kostka Polynomials

```@docs
kostka_polynomial
```

## Schur Polynomials

```@docs
schur_polynomial
```

## Enumerative functions

```@docs
num_partitions
catalan
stirling1
stirling2
lucas
```

## Quantum numbers

```@docs
quantum_number
quantum
```

## Index

```@index
```
