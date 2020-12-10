################################################################################
# Multipartitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Multipartition, multipartitions, multisetpartitions

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

"""
    multisetpartitions(n::Integer)

A list of all multisetpartitions of an integer n >= 0.

The performance will suffer by casting n into a smaller integer type, e.g.
```
multisetpartitions(Int8(20))
```
"""
function multisetpartitions(n::Integer)

    #Argument checking
    n >= 0 || throw(ArgumentError("n >= 0 required"))

    # Use type of n
    T = typeof(n)

    # Some trivial cases
    if n == 0
        return Multipartition{T}[Multipartition{T}([Partition{T}([])])]
    elseif n == 1
        return Multipartition{T}[Multipartition{T}([Partition([1])])]
    end

    # Now, the algorithm starts
    MP = Multipartition{T}[]
    for p in partitions(n)
        append!(MP, multisetpartitions(p))
    end
    return MP
end



"""
    multisetpartitions(p::Partition)

A list of all possible multisetpartitions of a Partition, by regrouping its parts in Partitions.

The algorithm used is the algorithm M by A. Zoghbi and I. Stojmenovic, "The Art of Computer Programming - A Draft oF Sections 7.2.1.4-5: Generating all Partitions", 39–40 http://www.cs.utsa.edu/~wagner/knuth/fasc3b.pdf. De-gotoed, index-shifted and generalized.
"""
function multisetpartitions(p::Partition)
  T = typeof(getindex(p,1))
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
    multisetpartitions(n::Integer, r::Integer)

A list of all multisetpartitions of an integer n >= 0 into r >= 1 parts.
"""
function multisetpartitions(n::Integer, r::Integer)

  #Argument checking
  n >= 0 || throw(ArgumentError("n >= 0 required"))
  r >= 1 || throw(ArgumentError("r >= 1 required"))

  # Use type of n
  T = typeof(n)

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
      append!(MP,multisetpartitions(p,r))
    end
  end
  return MP
end



"""
    multisetpartitions(p::Partition, r::Integer)

A list of all possible r-restricted multisetpartitions of a Partition, by regrouping its parts into Partitions.

The algorithm used is the algorithm M by A. Zoghbi and I. Stojmenovic, "The Art of Computer Programming - A Draft oF Sections 7.2.1.4-5: Generating all Partitions", 39–40 http://www.cs.utsa.edu/~wagner/knuth/fasc3b.pdf. De-gotoed, index-shifted and generalized.

The algorithm is almost the same as multisetpartitions(p::Partition), only part M4 of the algorithm was altered. The algorithm does the same computation but outputs only r-restricted multisetpartitions
"""
function multisetpartitions(p::Partition, r::Integer)
  T = typeof(getindex(p,1))
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
