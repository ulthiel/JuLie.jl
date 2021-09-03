# Partitions and the like

## Compositions
```@docs
Composition
compositions
num_compositions
```

## Partitions
```@docs
Partition
partitions
num_partitions
dominates
conjugate
getelement
ascending_partitions
```

## Multipartitions
```@docs
Multipartition
multipartitions
num_multipartitions
sum(P::Multipartition{T}) where T<:Integer
```

## Multiset partitions
```@docs
Multiset_partition
multiset_partitions
```

## Tableaux
```@docs
Tableau
shape
weight
reading_word
is_semistandard
semistandard_tableaux
is_standard
standard_tableaux
hook_length
hook_lengths
num_standard_tableaux
schensted
bump!
```
