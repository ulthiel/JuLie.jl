################################################################################
# Multiset_partitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Multiset_partition, multiset_partitions, partition_to_partcount, partcount_to_partition
#export union, union!

"""
    Multiset_partition{T}

Multiset-partitions are generalizations of partitions. An r-component **multiset-partition** of an integer ``n`` is a multiset(a set where each element can be contained multiple times) of partitions ``λ¹, λ², …, λʳ`` where each ``λⁱ`` is a partition of some integer ``nᵢ ≥ 1`` and the ``nᵢ`` sum to ``n``. As for partitions, we have implemented an own type `Multiset_partition{T}`. As with partitions, you can can use smaller integer types to increase performance.

# Example
```julia-repl
julia> P = Multiset_partition( [2,1], [4], [3,2,1] )
{[2, 1], [4], [3, 2, 1]}
julia> sum(P)
13
julia> Multiset_partition( Array{Int8,1}[[2,1], [4], [3,2,1]] ) #Using 8-bit integers
{Int8[2, 1], Int8[4], Int8[3, 2, 1]}
```

Since Multiset-partitions are unordered sets, you can't call an explicit element, however, you can iterate over a Multiset\\_partition.
# Example
```julia-repl
julia> MSP = Multiset_partition( [2,1], [4], [3,2,1] )
{[2, 1], [4], [3, 2, 1]}
julia> for p in MSP println(p) end
[2, 1]
[4]
[3, 2, 1]
```

"""
struct Multiset_partition{T}
  msp::Dict{Partition{T},Int}
end

"""
    Multiset_partition()
    Multiset_partition{T}() where T<:Integer

Returns an empty **Multiset_partition**.
"""
Multiset_partition() = Multiset_partition{Int}(Dict{Partition{Int},Int}())
Multiset_partition{T}() where T<:Integer = Multiset_partition{T}(Dict{Partition{T},Int}())

"""
    Multiset_partition(msp::Array{Partition{T},1}) where T<:Integer
    Multiset_partition(msp::Array{Array{T,1},1}) where T<:Integer
    Multiset_partition(p::Partition{T}...) where T<:Integer
    Multiset_partition(p::Array{T,1}...) where T<:Integer

Generates a **Multiset_partition** containing the Partitions `p` or the Partitions from `msp` respectively.
"""
function Multiset_partition(msp::Array{Partition{T},1}) where T<:Integer
  m = Dict{Partition{T}, Int}(p => 0 for p in msp)
  for p in msp
    m[p] = m[p] + 1
  end
  return Multiset_partition{T}(m)
end

# More convenient constructors
function Multiset_partition(msp::Array{Array{T,1},1}) where T<:Integer
   return Multiset_partition(Partition{T}[Partition(p) for p in msp])
end

function Multiset_partition(p::Partition{T}...) where T<:Integer
  m = Dict{Partition{T}, Int}(part => 0 for part in p)
  for part in p
    m[part] = m[part] + 1
  end
  return Multiset_partition{T}(m)
end

# More convenient constructors
function Multiset_partition(p::Array{T,1}...) where T<:Integer
   return Multiset_partition([Partition(part) for part in p])
end


function Base.show(io::IO, ::MIME"text/plain", MSP::Multiset_partition)
  print(io, "{")
  first = true
  for p in keys(MSP.msp)
    for i = 1:MSP[p]
      if first
        first = false
      else
        print(io, ", ")
      end
      print(io, p)
    end
  end
  print(io, "}")
end


"""
    push!(MSP::Multiset_partition, p::Partition, incr::Int = 1)

Adds the Partition `p` to the Multiset-partition `MSP`.
`incr` defines how often p should be added to `MSP`
# Example
```julia-repl
julia> MSP = Multiset_partition( [4], [3,1] )
{[4], [3, 1]}
julia> push!(MSP, Partition([5,2]))
{[4], [5, 2], [3, 1]}
julia> push!(MSP, Partition([7]), 3)
{[4], [5, 2], [3, 1], [7], [7], [7]}
```
"""
function Base.push!(MSP::Multiset_partition, p::Partition, incr::Int = 1)
  incr > 0 || throw(ArgumentError("incr > 0 required"))
  if haskey(MSP.msp, p)
    MSP.msp[p] += incr
  else
    MSP.msp[p] = incr
  end
  return MSP
end


"""
    setindex!(MSP::Multiset_partition, x::Integer, p::Partition)

Sets the multiplicity of the Partition `p` to `x`.
# Example
```julia-repl
julia> MSP = Multiset_partition( [4], [3,1] )
{[4], [3, 1]}
julia> setindex!(MSP, 3, Partition([4]))
{[4], [4], [4], [3, 1]}
julia> setindex!(MSP, 0, Partition([3, 1]))
{[4], [4], [4]}
```
"""
function Base.setindex!(MSP::Multiset_partition, x::Integer, p::Partition)
  if x==0 && haskey(MSP.msp, p)
    delete!(MSP.msp, p)
  elseif x!=0
    MSP.msp[p] = x
  end
  return MSP
end

"""
    union(MSP::Multiset_partition, partitions::Partition ...)

Returns a new Multiset_partition, containing the Partitions from `MSP` and `partitions`.
"""
function Base.union(MSP::Multiset_partition, partitions::Partition ...)
  MSPc = Multiset_partition(Base.copy(MSP.msp))
  for p in partitions
    push!(MSPc,p)
  end
  return MSPc
end

"""
    union!(MSP::Multiset_partition, partitions::Partition ...)

Adds the Partitions `partitions` to `MSP` and returns it.
"""
function Base.union!(MSP::Multiset_partition, partitions::Partition ...)
  for p in partitions
    push!(MSP,p)
  end
  return MSP
end

"""
    getindex(MSP::Multiset_partition, p::Partition)

Returns the multiplicity of the Partition `p` in `MSP`.
# Example
```julia-repl
julia> MSP = Multiset_partition( [4], [4], [3,1] )
{[4], [4], [3, 1]}
julia> getindex(MSP, Partition([4]))
2
julia> getindex(MSP, Partition([2,2]))
0
```
"""
function Base.getindex(MSP::Multiset_partition, p::Partition)
  if haskey(MSP.msp, p)
    return MSP.msp[p]
  else
    return 0
  end
end

"""
    collect(MSP::Multiset_partition{T}) where T<:Integer

Returns an Array{T,1} of all Partitions in `MSP`.
# Example
```julia-repl
julia> MSP = Multiset_partition( [4], [4], [3,1] )
{[4], [4], [3, 1]}
julia> collect(MSP)
3-element Array{Partition{Int64},1}:
 [4]
 [4]
 [3, 1]
```
"""
function Base.collect(MSP::Multiset_partition{T}) where T<:Integer
  P = Array{Partition{T},1}(undef, length(MSP))
  k = 1
  for p in keys(MSP.msp)
    for i = 1:MSP[p]
      P[k] = copy(p)
      k += 1
    end
  end
  return P
end

function Base.copy(MSP::Multiset_partition)
  return Multiset_partition(copy(MSP.msp))
end

function Base.:(==)(MSP1::Multiset_partition, MSP2::Multiset_partition)
  if keys(MSP1.msp)!=keys(MSP2.msp)
    return false
  else
    for p in keys(MSP1.msp)
      if MSP1[p]!=MSP2[p]
        return false
      end
    end
  end
  return true
end

"""
    isempty(MSP::Multiset_partition)

Returns `true` if the Multiset-partition `MSP` is empty.
"""
function Base.isempty(MSP::Multiset_partition)
  return isempty(MSP.msp)
end

function Base.iterate(MSP::Multiset_partition)
  Keys = Base.collect(keys(MSP.msp))
  if !isempty(MSP)
    return Keys[1], (1, 1, Keys)
  else
    return
  end
end

function Base.iterate(MSP::Multiset_partition{T}, state) where T<:Integer #state = (1,0,collect(keys(MSP.msp)))
  i,j,Keys = state
  j += 1
  if j<=MSP[Keys[i]]
    return Keys[i], (i, j, Keys)
  else
    i += 1
    j = 1
    if i<=length(Keys)
      return Keys[i], (i, j, Keys)
    else
      return
    end
  end
end

"""
    sum(MSP::Multiset_partition{T}) where T<:Integer

If `MSP` is a multiset-partition of the integer ``n``, this function returns ``n``.
"""
function Base.sum(MSP::Multiset_partition{T}) where T<:Integer
  s = zero(T)
  for p in keys(MSP.msp)
    s += MSP[p]*sum(p)
  end
  return s
end


"""
    length(MSP::Multiset_partition{T}) where T<:Integer

Returns the amount of Partitions in `MSP`.
"""
function Base.length(MSP::Multiset_partition{T}) where T<:Integer
  s = zero(T)
  for p in keys(MSP.msp)
    s += MSP[p]
  end
  return s
end

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
        return Multiset_partition{T}[Multiset_partition{T}()]
    elseif n == 1
        return Multiset_partition{T}[Multiset_partition([Partition(T[1])])]
    end

    # Now, the algorithm starts
    MSPs = Multiset_partition{T}[]
    for p in partitions(n)
        append!(MSPs, multiset_partitions(p))
    end
    return MSPs
end


"""
    multiset_partitions(p::Partition{T})  where T<:Integer

A list of all possible multiset_partitions of a Partition, by regrouping its parts into Partitions.

The algorithm used is the algorithm M by , ["The Art of Computer Programming - Volume 4A, Combinatorial Algorithms, Part 1"](http://www.cs.utsa.edu/~wagner/knuth/fasc3b.pdf) by Donald E. Knuth(2011), 429–430. De-gotoed, index-shifted and generalized.
"""
function multiset_partitions(p::Partition{T})  where T<:Integer
  if p == Partition(T[])
    return Multiset_partition{T}[Multiset_partition{T}()]
  end
  MSPs = Multiset_partition{T}[]

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
      msp = Multiset_partition{T}()
      i_f = 1
      while i_f <= l
        partcount = zeros(T,p[1])
        for ii = f[i_f]:f[i_f+1]-1
          partcount[c[ii]] = v[ii]
        end
        push!(msp, partcount_to_partition(partcount))
        i_f += 1
      end
      push!(MSPs, msp)

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
      return MSPs
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
    return Multiset_partition{T}[]
  elseif n == r
    return Multiset_partition{T}[setindex!(Multiset_partition{T}(), r, Partition{T}([1]))]
  end

  # Now, the algorithm starts
  MSPs = Multiset_partition{T}[]
  for p in partitions(n)
    if length(p) >= r
      append!(MSPs, multiset_partitions(p,r))
    end
  end
  return MSPs
end



"""
    multiset_partitions(p::Partition{T}, r::Integer) where T<:Integer

A list of all possible ``r``-restricted multiset_partitions of a Partition, by regrouping its parts into Partitions.

The algorithm used is a version of the algorithm M by , "The Art of Computer Programming - Volume 4A, Combinatorial Algorithms, Part 1" by Donald E. Knuth, 429–430 http://www.cs.utsa.edu/~wagner/knuth/fasc3b.pdf. De-gotoed, index-shifted and generalized.
"""
function multiset_partitions(p::Partition{T}, r::Integer) where T<:Integer
  #The algorithm is almost the same as multiset_partitions(p::Partition), only part M4 of the algorithm was altered. The algorithm does the same computation but outputs only r-restricted multiset_partitions.

  MSPs = Multiset_partition{T}[]

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
        msp = Multiset_partition{T}()
        i_f = 1
        while i_f <= l
          partcount = zeros(T,p[1])
          for ii = f[i_f]:f[i_f+1]-1
            partcount[c[ii]] = v[ii]
          end
          push!(msp, partcount_to_partition(partcount))
          i_f += 1
        end
        push!(MSPs, msp)
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
      return MSPs
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
    return T[]
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

  if isempty(pc)
    return Partition{T}(T[])
  end

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
