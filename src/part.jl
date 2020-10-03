################################################################################
# Functions for partitions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export partitions

"""
    partitions(n::Integer;alg="zs1")

A list of all partitions of an integer n >= 0. Conventions are explained below.

A partition of a positive integer n is a *decreasing* sequence n1 >= n2 >= ... of positive integers whose sum is equal to n. This can be encoded as an array.

**Note.** For efficiency, we assume n < 128 and use arrays of 8-bit integers for partitions. Producing the whole list of partitions for n >= 128 is probably not something you want to do anyways.

The *default* algorithm "zs1" is the algorithm ZS1 by A. Zoghbi and I. Stojmenovic, "Fast algorithms for generating integer partitions", Int. J. Comput. Math. 70 (1998), no. 2, 319–332. Here, the partitions are produced in lexicographically *descending* order.

For testing purposes we have implemented two further algorithms "ks" and "m", see below for references. By design these work with "inverted" partitions, i.e. *increasing* sequences, and they are produced in *ascending* order. There's not a huge speed difference to "zs1":
```
julia> @btime x=partitions(90);
 3.979 s (56634200 allocations: 6.24 GiB)

julia> @btime x=partitions(90,alg="ks");
 3.326 s (56634200 allocations: 6.24 GiB)

julia> @btime x=partitions(90,alg="m");
 3.464 s (56634200 allocations: 6.24 GiB)
```
The alternative algorithms are:
1. "ks" is the algorithm AccelAsc (Algorithm 4.1) by J. Kelleher and B. O'Sullivan, "Generating All Partitions: A Comparison Of Two Encodings", https://arxiv.org/pdf/0909.2331.pdf, May 2014.
2. "m" is Algorithm 6 by M. Merca, "Fast Algorithm for Generating Ascending Compositions", J. Math Model. Algor. (2012) 11:89–104. This is similar to "ks".
"""
function partitions(n::Integer;alg="zs1",sort="desc")

  #Argument checking
  n in 0:127 || throw(ArgumentError("0 =< n < 128 required"))

  # Some trivial cases
  if n==0
    return Vector{Int8}[ [] ]
  elseif n==1
    return Vector{Int8}[ [1] ]
  else

    if alg=="ks"
      # This is algorithm AccelAsc (Algorithm 4.1) from the preprint
      # "Generating All Partitions: A Comparison Of Two Encodings"
      # by J. Kelleher and B. O'Sullivan, May 2014
      # https://arxiv.org/pdf/0909.2331.pdf
      # Partition sorting is ascending
      P = Vector{Int8}[]  #this will be the array of all partitions
      a = zeros(Int8, n)
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
      # This is Algorithm 6 in
      # "Fast Algorithm for Generating Ascending Compositions"
      # by M. Merca
      # J Math Model Algor (2012) 11:89–104.
      # I think it's similar to "ks" and doesn't seem to be more
      # efficient.
      P = Vector{Int8}[]  #this will be the array of all partitions
      a = zeros(Int8, n)
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

    elseif alg=="zs1"
      # This is algorithm ZS1 from A. Zoghbi, I. Stojmenovic
      # "Fast algorithms for generating integer partitions"
      # Int. J. Comput. Math. 70 (1998), no. 2, 319–332.
      # Partition sorting is descending
      P = Vector{Int8}[]  #this will be the array of all partitions
      k = 1
      q = 1
      d = fill( Int8(1), n )
      d[1] = n
      push!(P, d[1:1])
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
        push!(P, d[1:k])
      end
      return P #alg zs1

    end
  end
end

"""
    partitions(m::Integer, n::Integer, l1::Integer, l2::Integer; z=0)

All partitions of an integer m >= 0 into n >= 0 parts with lower bound l1>=0 and upper bound l2>=l1. Parameter z should be set to 0 for arbitrary choice of parts (*default*), 1 for distinct parts. The partitions are produced in  *decreasing* order.

**Note.** For efficiency, we assume m < 128 and use arrays of 8-bit integers for partitions.

The algorithm used is "parta" from "Algorithm 29. Efficient Algorithms for Doubly and Multiply Restricted Partitions" by W. Riha and K. R. James (1976). De-gotoed by Elisa!
"""
function partitions(m::Integer, n::Integer, l1::Integer, l2::Integer; z=0)

  #Argument checking
  m in 0:127 || throw(ArgumentError("0 <= m < 128 required"))

  #Argument checking
  if n < 0
    throw(ArgumentError("n >= 0 required."))
  end

  if m == 0
    if n == 0
      return Vector{Int8}[ Int8[] ]
    else
      return  Vector{Int8}[ ]
    end
  end

  if n == 0
    return  Vector{Int8}[ ]
  end

  if n > m
    return Vector{Int8}[ ]
  end

  try
    m = convert(Int8, m)
    n = convert(Int8, n)
  catch
    throw(ArgumentError("m,n must fit into Int8."))
  end

  #Algorithm starts here
  P = Vector{Int8}[]  #this will be the array of all partitions
  x = zeros(Int8, n)
  y = zeros(Int8, n)
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
      push!(P, x[1:n])

      if i<n && m>1
        m = 1
        x[i] = x[i]-1
        i = i+1
        x[i] = y[i] + 1
        num = num + 1
        push!(P, x[1:n])
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



# The code below still has to be fixed.

#=
function partitions(mu::Array{Integer,1}, m::Integer, v::Array{Integer,1}, n::Integer)
  r = length(v)
  j = 1
  k = mu[1]
  ll = v[1]
  x = zeros(Int8, n)
  y = zeros(Int8, n)
  i_1 = 0
  P = zeros(Int8, n)

  num = 0
  lgotob2 = false
  lgotob1 = true

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

  if m = 0
    println(x)
    return P
  end

  i = 1
  m = m + y[1]

  while lgotob1 == true
    if !lgotob2
      for j = mu[r]:-1:1
        if m<=lr
          lgotb2 = true
          break
        end
        x[i]=lr
        ii[i] = r - 1
        i = i + 1
        m = m - lr + y[i]
      end #for j

      if !lgotob2
        r = r - 1
      end

      lgotob2 = true
    end #if

    if lgotob2
      while v[r] > m
        r = r - 1
      end

      lr = v[r]
      if m = lr
        x[i] = lr
        println(x)
        r = r  - 1
        lr = v[r]

      end #if
      k = y[i]
      if lr > k && m - lr <= (n-i)*(lr - ll)
        continue
      else
        x[i] = k
      end #if
      i_1 = i - 1
      for i=i_1:-1:1
        r = ii[i]
        lr = v[r]
        m = m + x[i] - k
        k = y[i]

        if lr > k && m - lr <= (n-i)*(lr-ll)
          break
        else
          x[i] = k
        end #if
        lgotob1 = false
      end #for

    end #if lgotob2
  end #while
end
=#
