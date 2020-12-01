# JuLie.jl
A Julia package for Combinatorics

```@contents
Depth = 3
```

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

partitions
ascending_partitions
```

## Multipartitions

```@docs
Multipartition
multipartitions
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

