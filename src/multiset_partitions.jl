################################################################################
# Multipartitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export multiset_partitions, partition_to_partcount, partcount_to_partition


# struct Multipartition{T} <: AbstractArray{Partition{T},1}
#    mp::Array{Partition{T},1}
# end
#
#
#
# function Base.show(io::IO, ::MIME"text/plain", MP::Multipartition)
#   print(io, MP.mp)
# end
#
# function Base.size(MP::Multipartition)
#   return size(MP.mp)
# end
#
# function Base.length(MP::Multipartition)
#   return length(MP.mp)
# end
#
# function Base.getindex(MP::Multipartition, i::Int)
#   return getindex(MP.mp,i)
# end

"""
    multiset_partitions(n::T) where T<:Integer

A list of all multiset_partitions of an integer ``n ⋝ 0``.

The performance will suffer by casting ``n`` into a smaller integer type, e.g.
```
multiset_partitions(Int8(20))
```
"""
function multiset_partitions(n::T) where T<:Integer

    #Argument checking
    n >= 0 || throw(ArgumentError("n >= 0 required"))

    # Some trivial cases
    if n == 0
        return Multipartition{T}[Multipartition{T}([Partition{T}([])])]
    elseif n == 1
        return Multipartition{T}[Multipartition{T}([Partition([1])])]
    end

    # Now, the algorithm starts
    MP = Multipartition{T}[]
    for p in partitions(n)
        append!(MP, multiset_partitions(p))
    end
    return MP
end


"""
    multiset_partitions(p::Partition{T})  where T<:Integer

A list of all possible multiset_partitions of a Partition, by regrouping its parts into Partitions.

The algorithm used is the algorithm M by , ["The Art of Computer Programming - Volume 4A, Combinatorial Algorithms, Part 1"](http://www.cs.utsa.edu/~wagner/knuth/fasc3b.pdf) by Donald E. Knuth(2011), 429–430. De-gotoed, index-shifted and generalized.
"""
function multiset_partitions(p::Partition{T})  where T<:Integer
  MP = Multipartition{T}[]

  partcount = partition_to_partcount(p)
  n::T = sum(partcount)


  # M1 : Initialize
  nn = Int((n*(n+1))/2+1)
  f = zeros(T,n+1)   #f : stack frame array
  c = zeros(T,nn)   #c : component number
  u = zeros(T,nn)   #u : yet unpartitioned amount in c remaining
  v = zeros(T,nn)   #v : c component of the current part

  m = 0
  for j = 1:length(partcount)
    if partcount[j] != 0
      m = m + T(1)
      c[m] = j
      u[m] = partcount[j]
      v[m] = partcount[j]
    end
  end
  a = 1
  l = 1
  b = m + 1
  f[1] = 1
  f[2] = m + 1
  gotoM2 = true

  while true
    # M2 : Subtract v from u
    if gotoM2
      j = a
      k = b
      while j < b
        u[k] = u[j] - v[j]
        if u[k] >= v[j]
          c[k] = c[j]
          v[k] = v[j]
          k += 1
          j += 1
        else
          if u[k] != 0
            c[k] = c[j]
            v[k] = u[k]
            k += 1
          end
          j += 1
          while j < b
            if u[j] != v[j]
              u[k] = u[j] - v[j]
              c[k] = c[j]
              v[k] = u[k]
              k += 1
            end
            j += 1
          end #while
        end #else
      end #while

      # M3 : Push if nonzero
      if k > b
        a = b
        b = k
        l += 1
        f[l+1] = b
        gotoM2 = true
        continue
      end

      # M4 : Visit a partition
      mp = Vector{Partition{T}}(undef, l)
      i_f = 1
      while i_f <= l
        partcount = zeros(T,p[1])
        for ii = f[i_f]:f[i_f+1]-1
          partcount[c[ii]] = v[ii]
        end
        mp[i_f] = partcount_to_partition(partcount)
        i_f = i_f + 1
      end
      push!(MP, Multipartition{T}(mp))

    end #if gotoM2

    # M5 : Decrease v
    j = b - 1
    while v[j] == 0
      j -= 1
    end
    if j!=a || v[j]!=1
      v[j] -= 1
      for k = j+1:b-1
        v[k] = u[k]
      end
      gotoM2 = true
      continue
    end

    # M6 : Backtrack
    if l == 1
      return MP
    end
    l -= 1
    b = a
    a = f[l]
    gotoM2 = false
  end#while true
end



"""
    multiset_partitions(n::T, r::Integer) where T<:Integer

A list of all multiset_partitions of an integer ``n ⋝ 0`` into ``r ⋝ 1`` parts.
"""
function multiset_partitions(n::T, r::Integer) where T<:Integer

  #Argument checking
  n >= 0 || throw(ArgumentError("n >= 0 required"))
  r >= 1 || throw(ArgumentError("r >= 1 required"))

  # Some trivial cases
  if n < r
    return Multipartition{T}[]
  elseif n == r
    return Multipartition{T}[Multipartition{T}(fill(Partition{T}([T(1)]),r))]
  end

  # Now, the algorithm starts
  MP = Multipartition{T}[]
  for p in partitions(n)
    if length(p) >= r
      append!(MP,multiset_partitions(p,r))
    end
  end
  return MP
end



"""
    multiset_partitions(p::Partition{T}, r::Integer) where T<:Integer

A list of all possible ``r``-restricted multiset_partitions of a Partition, by regrouping its parts into Partitions.

The algorithm used is a version of the algorithm M by , "The Art of Computer Programming - Volume 4A, Combinatorial Algorithms, Part 1" by Donald E. Knuth, 429–430 http://www.cs.utsa.edu/~wagner/knuth/fasc3b.pdf. De-gotoed, index-shifted and generalized.
"""
function multiset_partitions(p::Partition{T}, r::Integer) where T<:Integer
  #The algorithm is almost the same as multiset_partitions(p::Partition), only part M4 of the algorithm was altered. The algorithm does the same computation but outputs only r-restricted multiset_partitions.

  MP = Multipartition{T}[]

  partcount = partition_to_partcount(p)
  n::T = sum(partcount)


  # M1 : Initialize
  nn = Int((n*(n+1))/2+1)
  f = zeros(T,n+1)   #f : stack frame array
  c = zeros(T,nn)   #c : component number
  u = zeros(T,nn)   #u : yet unpartitioned amount in c remaining
  v = zeros(T,nn)   #v : c component of the current part

  m::T = 0
  for j = 1:length(partcount)
    if partcount[j] != 0
      m = m + 1
      c[m] = j
      u[m] = partcount[j]
      v[m] = partcount[j]
    end
  end
  a = 1
  l = 1
  b = m + 1
  f[1] = 1
  f[2] = m + 1
  gotoM2 = true

  while true
    # M2 : Subtract v from u
    if gotoM2
      j = a
      k = b
      while j < b
        u[k] = u[j] - v[j]
        if u[k] >= v[j]
          c[k] = c[j]
          v[k] = v[j]
          k += 1
          j += 1
        else
          if u[k] != 0
            c[k] = c[j]
            v[k] = u[k]
            k += 1
          end
          j += 1
          while j < b
            if u[j] != v[j]
              u[k] = u[j] - v[j]
              c[k] = c[j]
              v[k] = u[k]
              k += 1
            end
            j += 1
          end #while
        end #else
      end #while

      # M3 : Push if nonzero
      if k > b
        a = b
        b = k
        l += 1
        f[l+1] = b
        gotoM2 = true
        continue
      end

      # M4 : Visit a partition
      if l==r
        mp = Vector{Partition{T}}(undef, l)
        i_f = 1
        while i_f <= l
          partcount = zeros(T,p[1])
          for ii = f[i_f]:f[i_f+1]-1
            partcount[c[ii]] = v[ii]
          end
          mp[i_f] = partcount_to_partition(partcount)
          i_f = i_f + 1
        end
      push!(MP, Multipartition{T}(mp))
      end
    end #if gotoM2

    # M5 : Decrease v
    j = b - 1
    while v[j] == 0
      j -= 1
    end
    if j!=a || v[j]!=1
      v[j] -= 1
      for k = j+1:b-1
        v[k] = u[k]
      end
      gotoM2 = true
      continue
    end

    # M6 : Backtrack
    if l == 1
      return MP
    end
    l -= 1
    b = a
    a = f[l]
    gotoM2 = false
  end#while true
end


"""
    partition_to_partcount(p::Partition{T})  where T<:Integer

returns the **part-count** representation of a partition ``p``, where the ``n``-th element is the count of appearances of ``n`` in ``p``.

```
julia> partition_to_partcount([5,3,3,3,2,1,1])
  5-element Array{Int64,1}:
  2
  1
  3
  0
  1
```

for performance, partitions with trailing zeroes will not be allowed.
"""
function partition_to_partcount(p::Partition{T})  where T<:Integer

  if isempty(p) || getindex(p,1) == 0
    return []
  end

  p[end]!=0 || throw(ArgumentError("p can't have any trailing zeroes"))

  pc = zeros(T,p[1])

  for i = 1:length(p)
    pc[p[i]] += 1
  end
  return pc

end


"""
    partcount_to_partition(pc::Array{T,1}) where T<:Integer

returns the partition from a part-count representation ``pc`` of a partition.
```
julia> partcount_to_partition([2,0,1])
  [3,1,1]
```
"""
function partcount_to_partition(pc::Array{T,1}) where T<:Integer

  l = sum(pc)       #length of resulting partition
  if l == 0
    return Partition{T}([0])
  end

  p = zeros(T,l)

  k=1
  for i = length(pc):-1:1
    for j = 1:pc[i]
      p[k] = i
      k += 1
    end
  end
  return Partition{T}(p)
end
