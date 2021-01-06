################################################################################
# Multipartitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Multipartition, multipartitions

"""
    struct Multipartition{T} <: AbstractArray{Partition{T},1}

An r-component **multipartition** of an integer n is an r-tuple of partitions λ¹, λ², …, λʳ where each λⁱ is a partition of some integer aᵢ ≥ 0 and the aᵢ sum to n. As for partitions, we have implemented an own type ```Multipartition{T}``` which is a subtype of ```AbstractArray{Partition{T},1}```. Here's an example:
```
julia> P=Multipartition( [[2,1], [], [3,2,1]] )
julia> sum(P)
9
julia> P[2]
Int64[]
```
As with partitions, you can cast into smaller integer types to increase performance, e.g.
```
julia> Multipartition( Array{Int8,1}[[2,1], [], [3,2,1]] )
```
"""
struct Multipartition{T} <: AbstractArray{Partition{T},1}
   mp::Array{Partition{T},1}
end


function Base.show(io::IO, ::MIME"text/plain", MP::Multipartition)
  print(io, MP.mp)
end

function Base.size(MP::Multipartition)
  return size(MP.mp)
end

function Base.length(MP::Multipartition)
  return length(MP.mp)
end

function Base.getindex(MP::Multipartition, i::Int)
  return getindex(MP.mp,i)
end

# More convenient constructors
function Multipartition(mp::Array{Array{T,1},1}) where T<:Integer
   return Multipartition([Partition(p) for p in mp])
end

# This is only called when the empty array is part of mp (because then it's
# "Any" type and not of Integer type).
function Multipartition(mp::Array{Array{Any,1},1})
   return Multipartition([Partition(p) for p in mp])
end


"""
    function sum(P::Multipartition{T}) where T<:Integer

If P is a multipartition of the integer n, this function returns n.
"""
function Base.sum(P::Multipartition{T}) where T<:Integer
  s = zero(T)
  for i=1:length(P)
    s += sum(P[i])
  end
  return s
end


"""
    function multipartitions(n::T, r::Integer) where T<:Integer

A list of all r-component multipartitions of n. As for partitions, you can cast n into smaller type for efficiency, e.g.
```
julia> multipartitions(Int8(3),2)
```
"""
function multipartitions(n::T, r::Integer) where T<:Integer
  #Argument checking
  n >= 0 || throw(ArgumentError("n >= 0 required"))
  r >= 1 || throw(ArgumentError("r >= 1 required"))

  MP = Multipartition{T}[]

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
        push!(MP, Multipartition{T}(copy(mp)))
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
