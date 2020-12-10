################################################################################
# Multipartitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export MultiPartition, multipartitions

"""
    struct MultiPartition{T} <: AbstractArray{Partition{T},1}

An ``r``-component **multipartition** of an integer ``n`` is an ``r``-tuple of partitions ``\\lambda^{(1)},...,\\lambda^{(r)}`` where each ``\\lambda^{(i)}`` is a partition of some ``a_i`` and the ``a_i`` sum to ``n``.

You can create a multipartition with
```
MultiPartition( [[2,1], [], [3,2,1]] )
```
As with partitions, you can cast into smaller integer types to increase performance:
```
MultiPartition( Array{Int8,1}[[2,1], [], [3,2,1]] )
```
"""
struct MultiPartition{T} <: AbstractArray{Partition{T},1}
   mp::Array{Partition{T},1}
end


function Base.show(io::IO, ::MIME"text/plain", MP::MultiPartition)
  print(io, MP.mp)
end

function Base.size(MP::MultiPartition)
  return size(MP.mp)
end

function Base.length(MP::MultiPartition)
  return length(MP.mp)
end

function Base.getindex(MP::MultiPartition, i::Int)
  return getindex(MP.mp,i)
end

# More convenient constructors
function MultiPartition(mp::Array{Array{T,1},1}) where T<:Integer
   return MultiPartition([Partition(p) for p in mp])
end

# This is only called when the empty array is part of mp (because then it's
# "Any" type and not of Integer type).
function MultiPartition(mp::Array{Array{Any,1},1})
   return MultiPartition([Partition(p) for p in mp])
end

"""
    function multipartitions(n::T,r::T) where T<:Integer

A list of all ``r``-component multipartitions of ``n``. As for partitions, you can cast n and r into smaller type for efficiency, e.g.
```
multipartitions(Int8(3),Int8(2))
```
"""
function multipartitions(n::T,r::T) where T<:Integer
  #Argument checking
  n >= 0 || throw(ArgumentError("n >= 0 required"))
  r >= 1 || throw(ArgumentError("r >= 1 required"))

  MP = MultiPartition{T}[]

  #recursively produces all Integer Arrays p of length r such that the sum of all the Elements equals n. Then calls recMultipartitions!
  function recP!(p::Array{T,1}, i::T, n::T) #where T<:Integer
    if i==length(p) || n==0
      p[i] = n
      recMultipartitions!(fill(Partition(T[]),r), p, T(1))
    else
      for j=0:n
        p[i] = T(j)
        recP!(copy(p), T(i+1), T(n-j))
      end
    end
  end

  #recursively produces all multipartitions such that the i-th partition sums up to p[i]
  function recMultipartitions!(mp::Array{Partition{T},1}, p::Array{T,1}, i::T) #where T<:Integer
    if i == length(p)
      for q in partitions(p[i])
        mp[i] = q
        push!(MP, MultiPartition{T}(copy(mp)))
      end
    else
      for q in partitions(p[i])
        mp[i] = q
        recMultipartitions!(copy(mp), p, T(i+1))
      end
    end
  end

  recP!(zeros(T,r), T(1), n)
  return MP
end
