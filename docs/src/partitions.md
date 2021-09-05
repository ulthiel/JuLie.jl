# Partitions and the like

## Partitions

```@docs
Partition
```

### Generating partitions

```@docs
partitions
ascending_partitions
num_partitions
```

### Operations on partitions
```@docs
conjugate
dominates
getindex_safe
```

## Tableaux
```@docs
Tableau
```

### Operations on tableaux

```@docs
hook_length
hook_lengths
shape
weight
reading_word
```

### Semistandard tableaux

```@docs
is_semistandard
semistandard_tableaux
```

### Standard tableaux

```@docs
is_standard
standard_tableaux
num_standard_tableaux
schensted
bump!
```

## Multipartitions

```@docs
Multipartition
```

### Generating multipartitions

```@docs
multipartitions
num_multipartitions
```

### Operations on multipartitions
```@docs
sum(P::Multipartition{T}) where T<:Integer
```

## Multiset partitions
```@docs
Multiset_partition
multiset_partitions
```

## Compositions
```@docs
Composition
compositions
num_compositions
```