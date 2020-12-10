################################################################################
# Partitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Partition, partitions, ascending_partitions, dominates



"""
    struct Partition{T} <: AbstractArray{T,1}

A **partition** of an integer ``n >= 0`` is a *decreasing* (convention) sequence ``n_1, n_2, \\ldots`` of positive integers whose sum is equal to ``n``. You can create a partition with
```
P=Partition([3,2,1])
```
and then work with it like with an array. In fact, Partition is a subtype of AbstractArray{T,1}. You can increase performance by using smaller integer types, e.g.
```
P=Partition(Int8[3,2,1])
```
Note that for efficiency the Partition constructor does not check whether the given array is in fact a partition, i.e. a decreasing sequence. That's your job.

I was thinking back and forth whether to implement an own structure for this because it's actually just an array of integers. But it makes sense since we have several functions just acting on partitons and it would be strange implementing them for arrays in general (where mostly they don't make sense). I was hesitating because I feared that an own structure for partitions will have a performance impact. But it does not! In my standard example creating the partitions of 90 there is really NO difference in runtime and memory consumption between using arrays and using an own structure.

The implementation of a subtype of AbstractArray is explained in [the Julia documentation](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).
"""
struct Partition{T} <: AbstractArray{T,1}
   p::Array{T,1}
end

# The following are functions to make the Partition struct array-like.
function Base.show(io::IO, ::MIME"text/plain", P::Partition)
  print(io, P.p)
end

function Base.size(P::Partition)
  return size(P.p)
end

function Base.length(P::Partition)
  return length(P.p)
end

function Base.getindex(P::Partition, i::Int)
  return getindex(P.p,i)
end

function Base.setindex!(P::Partition, x::Integer, i::Int)
  return setindex!(P.p,x,i)
end

# The empty array is of "Any" type, and this is stupid. We want it here
# to get it into the default type Int64. This constructor is also called by
# MultiPartition, and this casts the whole array into "Any" whenever there's
# the empty partition inside.
function Partition(p::Array{Any,1})
  return Partition(Array{Int64,1}(p))
end

"""
    partitions(n::Integer)

A list of all partitions of an integer n >= 0, produced in lexicographically *descending* order (like in SAGE, but opposite to GAP (you can apply reverse() to reverse the order)). The algorithm used is the algorithm ZS1 by A. Zoghbi and I. Stojmenovic, "Fast algorithms for generating integer partitions", Int. J. Comput. Math. 70 (1998), no. 2, 319–332.

You can increase performance by casting ``n`` into a smaller integer type, e.g.
```
partitions(Int8(90))
```
"""
function partitions(n::Integer)

  #Argument checking
  n >= 0 || throw(ArgumentError("n >= 0 required"))

  # Use type of n
  T = typeof(n)

  # Some trivial cases
  if n==0
    return Partition{T}[ Partition{T}([]) ]
  elseif n==1
    return Partition{T}[ Partition{T}([1]) ]
  end

  # Now, the algorithm starts
  P = Partition{T}[]  #this will be the array of all partitions
  k = 1
  q = 1
  d = fill( T(1), n )
  d[1] = n
  push!(P, Partition{T}(d[1:1]))
  while q != 0
    if d[q] == 2
      k += 1
      d[q] = 1
      q -= 1
    else
      m = d[q] - 1
      np = k - q + 1
      d[q] = m
      while np >= m
        q += 1
        d[q] = m
        np = np - m
      end
      if np == 0
        k = q
      else
        k = q + 1
        if np > 1
          q += 1
          d[q] = np
        end
      end
    end
    push!(P, Partition{T}(d[1:k]))
  end
  return P

end



"""
    ascending_partitions(n::Integer;alg="ks")

Instead of encoding a partition of an integer n >= 0 as a descending sequence (which is our convention), one can also encode it as an *ascending* sequence. In the papers below it is claimed that generating the list of all ascending partitions is more efficient than generating descending ones. To test this, I have implemented the algorithms:
1. "ks" (*default*) is the algorithm AccelAsc (Algorithm 4.1) by J. Kelleher and B. O'Sullivan, "Generating All Partitions: A Comparison Of Two Encodings", https://arxiv.org/pdf/0909.2331.pdf, May 2014.
2. "m" is Algorithm 6 by M. Merca, "Fast Algorithm for Generating Ascending Compositions", J. Math Model. Algor. (2012) 11:89–104. This is similar to "ks".
The ascending partitions are given here as arrays, not of type Partition since these are descending by convention.

I don't see a significant speed difference to the descending encoding:
```
julia> @btime partitions(Int8(90));
  3.376 s (56634200 allocations: 6.24 GiB)

julia> @btime ascending_partitions(Int8(90),alg="ks");
  3.395 s (56634200 allocations: 6.24 GiB)

julia> @btime ascending_partitions(Int8(90),alg="m");
  3.451 s (56634200 allocations: 6.24 GiB)
```

I am using "ks" as default since it looks slicker and I believe there is a tiny mistake in the publication of "m" (which I fixed).
"""
function ascending_partitions(n::Integer;alg="ks")

  #Argument checking
  n >= 0 || throw(ArgumentError("n >= 0 required"))

  # Use type of n
  T = typeof(n)

  # Some trivial cases
  if n==0
    return Vector{T}[ [] ]
  elseif n==1
    return Vector{T}[ [1] ]
  end

  # Now, the algorithm starts
  if alg=="ks"
    P = Vector{T}[]  #this will be the array of all partitions
    a = zeros(T, n)
    k = 2
    y = n-1
    while k != 1
      k -= 1
      x = a[k] + 1
      while 2*x <= y
        a[k] = x
        y -= x
        k += 1
      end
      l = k + 1
      while x <= y
        a[k] = x
        a[l] = y
        push!(P, a[1:l])
        x += 1
        y -= 1
      end
      y += x - 1
      a[k] = y + 1
      push!(P, a[1:k])
    end
    return P

  elseif alg=="m"
    P = Vector{T}[]  #this will be the array of all partitions
    a = zeros(T, n)
    k = 1
    x = 1
    y = n-1
    while true
      while 3*x <= y
        a[k] = x
        y = y-x
        k += 1
      end
      t = k + 1
      u = k + 2
      while 2*x <= y
        a[k] = x
        a[t] = x
        a[u] = y - x
        push!(P, a[1:u])
        p = x + 1
        q = y - p
        while p <= q
          a[t] = p
          a[u] = q
          push!(P, a[1:u])
          p += 1
          q -= 1
        end
        a[t] = y
        push!(P, a[1:t])
        x += 1
        y -= 1
      end
      while x<=y
        a[k] = x
        a[t] = y
        push!(P, a[1:t])
        x += 1
        y -= 1
      end
      y += x-1
      a[k] = y+1
      push!(P, a[1:k])
      k -= 1

      # I think there's a mistake in the publication
      # because here k could be zero and then we access
      # a[k].
      # That's why I do a while true and check k > 0 here.
      if k == 0
        break
      else
        x = a[k] + 1
      end
    end
    return P

  end

end



"""
    partitions(m::Integer, n::Integer, l1::Integer, l2::Integer; z=0)

All partitions of an integer m >= 0 into n >= 0 parts with lower bound l1>=0 and upper bound l2>=l1. Parameter z should be set to 0 for arbitrary choice of parts (*default*), 1 for distinct parts. The partitions are produced in  *decreasing* order.

The algorithm used is "parta" by W. Riha and K. R. James, "Algorithm 29. Efficient Algorithms for Doubly and Multiply Restricted Partitions" (1976). De-gotoed from ALGOL code by Elisa!
"""
function partitions(m::Integer, n::Integer, l1::Integer, l2::Integer; z=0)

  # Note that we are considering partitions of m here. I would switch m and n
  # but the algorithm was given like that and I would otherwise confuse myself
  # implementing it.

  #Argument checking
  m >= 0 || throw(ArgumentError("m >= 0 required"))
  n >= 0 || throw(ArgumentError("n >= 0 required"))

  # Use type of n
  T = typeof(m)
  n = convert(T, n)

  # Some trivial cases
  if m == 0
    if n == 0
      return Partition{T}[ Partition{T}([]) ]
    else
      return Partition{T}[]
    end
  end

  if n == 0
    return Partition{T}[]
  end

  if n > m
    return Partition{T}[]
  end

  #Algorithm starts here
  P = Partition{T}[]  #this will be the array of all partitions
  x = zeros(T, n)
  y = zeros(T, n)
  num = 0
  j = z*n*(n-1)
  m = m-n*l1-div(j,2)
  l2 = l2 - l1
  if m>=0 && m<=n*l2-j

    for i = 1:n
      x[i] = l1+z*(n-i)
      y[i] = x[i]
    end

    i = 1
    l2 = l2-z*(n-1)

    lcycle = true
    while lcycle
      lcycle = false
      if m > l2
        m = m-l2
        x[i] = y[i] + l2
        i = i + 1
        lcycle = true
        continue
      end

      x[i] = y[i] + m
      num = num + 1
      push!(P, Partition{T}(x[1:n]))

      if i<n && m>1
        m = 1
        x[i] = x[i]-1
        i = i+1
        x[i] = y[i] + 1
        num = num + 1
        push!(P, Partition{T}(x[1:n]))
      end

      for j = i-1:-1:1
        l2 = x[j] - y[j] - 1
        m = m + 1
        if m <= (n-j)*l2
          x[j] = y[j] + l2
          lcycle = true
          break
        end
        m = m + l2
        x[i] = y[i]
        i = j
      end

      if !lcycle
        break
      end
    end
  end

  return P
end



"""
    partitions(m::Integer, n::Integer)

All partitions of an integer m >= 0 into n >= 1 parts (no further restrictions). This simply calls partitions(m,n,1,m,z=0).
"""
function partitions(m::Integer, n::Integer)
  return partitions(m,n,1,m,z=0)
end




# The code below still has to be fixed, I forgot what the problem was.
# This is the (de-gotoed version of) algorithm partb by W. Riha and K. R. James, "Algorithm 29. Efficient Algorithms for Doubly and Multiply Restricted Partitions" (1976).
#=
"""
    partitions(mu::Array{Integer,1}, m::Integer, v::Array{Integer,1}, n::Integer)

All partitions of an integer m >= 0 into n >= 0 parts, where each part is an element in v and each v[i] occurse a maximum of mu[i] times. The partitions are produced in  *decreasing* order.

The algorithm used is a de-gotoed version of "partb" by W. Riha and K. R. James, "Algorithm 29. Efficient Algorithms for Doubly and Multiply Restricted Partitions" (1976).
"""
function partitions(mu::Array{Integer,1}, m::Integer, v::Array{Integer,1}, n::Integer)
  r = length(v)
  j = 1
  k = mu[1]
  ll = v[1]
  x = zeros(Int8, n)
  y = zeros(Int8, n)
  ii = zeros(Int8, n)
  i_1 = 0
  T=typeof(m)
  P = Partition{T}[]

  num = 0
  gotob2 = false
  gotob1 = true

  for i = n:-1:1
     x[i] = ll
     y[i] = ll
     k = k - 1
     m = m - ll
     if k == 0
       if j == r
         return P
       end
      j = j + 1
      k = mu[j]
      ll = v[j]
     end
   end #for i

  lr = v[r]
  ll = v[1]

  if m < 0 || m > n * (lr - ll)
    return P
  end

  if m == 0
    push!(P,Partition{T}(x[1:n]))
    return P
  end

  i = 1
  m = m + y[1]

  while gotob1 == true
    if !gotob2
      for j = mu[r]:-1:1
        if m<=lr
          gotob2 = true
          break
        end
        x[i]=lr
        ii[i] = r - 1
        i = i + 1
        m = m - lr + y[i]
      end #for j

      if !gotob2
        r = r - 1
      end

      gotob2 = true
    end #if

    if gotob2
      while v[r] > m
        r = r - 1
      end

      lr = v[r]
      if m == lr
        x[i] = lr
        push!(P,Partition{T}(x[1:n]))

        r = r - 1
        lr = v[r]
      end #if

      k = y[i]
      if lr > k && m - lr <= (n-i)*(lr - ll)
        gotob2 = false
        continue
      else
        x[i] = k
      end #if
      i_1 = i - 1
      for i_0=i_1:-1:1
        i = i_0
        r = ii[i]
        lr = v[r]
        m = m + x[i] - k
        k = y[i]
        if lr > k && m - lr <= (n-i)*(lr-ll)
          gotob2 = false
          break
        else
          x[i] = k
        end #if
      end #for
      if gotob2
        gotob1 = false
      end
    end #if gotob2
  end #while
  return P
end

=#


"""
    partition_to_partcount(p::Partition)

returns the part-count representation of a partition p, where the nth element is the count of appearances of n in p.

e.g. partition_to_partcount([5,3,3,3,2,1,1]) returns [2,1,3,0,1]

for performance, partitions with trailing zeroes will not be allowed
"""
function partition_to_partcount(p::Partition)

  T = typeof(getindex(p,1)) #Type of the elements in p

  if getindex(p,1) == 0
    return [getindex(p,1)]
  end

  pc = zeros(T,p[1])

  for i = 1:length(p)
    pc[p[i]] += 1
  end
  return pc

end

"""
    partcount_to_partition(pc::Array{Integer,1})

returns the partition from a part-count representation pc of a partition.

e.g. partcount_to_partition([2,0,1]) returns [3,1,1]
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


"""
    dominates(lambda::Partition, mu::Partition)

returns true if lambda >= mu according to the dominance order on partitions:
lambda >= mu  :<=>  lambda[1] + ... + lambda[i] >= mu[1] + ... + mu[i] for all i
"""
function dominates(lambda::Partition, mu::Partition)
  dif = 0
  i = 1
  while i <= min(length(lambda), length(mu))
    dif += lambda[i] - mu[i]
    i += 1
    if dif < 0
      return false
    end
  end
  if length(lambda) < length(mu)
    while i <= length(mu)
      dif -= mu[i]
      i += 1
    end
    if dif < 0
      return false
    end
  end
  return true
end
