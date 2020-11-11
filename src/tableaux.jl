################################################################################
# Tableaux
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Tableau, shape, semistandard_tableaux, is_standard, is_semistandard, schensted

struct Tableau{T} <: AbstractArray{AbstractArray{T,1},1}
   t::Array{Array{T,1},1}
end

function Base.show(io::IO, ::MIME"text/plain", Tab::Tableau)
  print(io, Tab.t)
end

function Base.size(Tab::Tableau)
  return size(Tab.t)
end

function Base.length(Tab::Tableau)
  return length(Tab.t)
end

function Base.getindex(Tab::Tableau, i::Int)
  return getindex(Tab.t,i)
end

function Base.getindex(Tab::Tableau, I::Vararg{Int, 2})
  return getindex(getindex(Tab.t,I[1]), I[2])
end

function shape(Tab::Tableau{T}) where T
  return Partition{T}([ length(Tab[i]) for i=1:length(Tab) ])
end


"""
   semistandard_tableaux(shape::Partition{T}, max_val=sum(shape)::Integer) where T<:Integer

returns an Array containing all semistandard tableaux of shape shape and maximal element<=max_val.
The tableaux are in lexicographic order from left to right and top to bottom
"""
function semistandard_tableaux(shape::Partition{T}, max_val=sum(shape)::T) where T<:Integer
  return semistandard_tableaux(Array{T,1}(shape), max_val)
end


 """
    semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer) where T<:Integer

returns an Array containing all semistandard tableaux of shape shape and maximal element<=max_val.
The tableaux are in lexicographic order from left to right and top to bottom
 """
function semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer) where T<:Integer
  SST = Array{Tableau{T},1}()
  len = length(shape)
  if max_val < len
    return ST
  end
  Tab = [Array{T}(fill(i,shape[i])) for i = 1:len]
  m = len
  n = shape[m]

  while true
    push!(SST, Tableau{T}(deepcopy(Tab)))

    #raise one element by 1
    while !(Tab[m][n]<max_val &&
      (n==shape[m] || Tab[m][n]<Tab[m][n+1]) &&
      (m==len || shape[m+1]<n || Tab[m][n]+1<Tab[m+1][n]))
      if n > 1
        n -= 1
      elseif m > 1
        m -= 1
        n = shape[m]
      else
        return SST
      end
    end

    Tab[m][n] += 1

    #minimize trailing elemnts
    if n < shape[m]
      i = m
      j = n + 1
    else
      i = m + 1
      j = 1
    end
    while (i<=len && j<=shape[i])
      if i==1
        Tab[1][j] = Tab[1][j-1]
      elseif j==1
        Tab[i][1] = Tab[i-1][1] + 1
      else
        Tab[i][j] = max(Tab[i][j-1], Tab[i-1][j] + 1)
      end
      if j < shape[i]
        j += 1
      else
        j = 1
        i += 1
      end
    end
    m = len
    n = shape[len]
  end
end

"""
   semistandard_tableaux(box_num::T, max_val=box_num::T) where T<:Integer

returns an Array containing all semistandard tableaux made from box_num boxes and maximal element<=max_val.
"""
function semistandard_tableaux(box_num::T, max_val=box_num::T) where T<:Integer
  SST = Array{Tableau{T},1}()
  shapes = partitions(box_num)

  for s in shapes
    if max_val >= length(s)
      append!(SST, semistandard_tableaux(s.p,max_val))
    end
  end

  return SST
end

"""
    schensted(sigma::Array{Integer,1})

An implementation of the Schensted algorithm from the Robinson-Schensted correspondence.
sigma represents the second line of a Permutation in two-line notation: 1->sigma[1] , 2->sigma[2] , ...
Returns a pair of standard Tableaux P,Q (insertion- and recording- tableaux)
"""
function schensted(sigma::Array{T,1}) where T<:Integer
  P = Tableau{T}([[sigma[1]]])
  Q = Tableau{T}([[1]])
  for i = 2:length(sigma)
    bump!(P, sigma[i], Q, i)
  end
  return P,Q
end


"""
    bump!(Tab::Tableau,x::Int)

Inserts x into Tab according to the Bumping algorithm by applying the Schensted insertion
"""
function bump!(Tab::Tableau,x::Integer)
  i = 1
  while i <= length(Tab)
    if Tab[i, length(Tab[i])] <= x
      push!(Tab[i], x)
      return Tab
    end
    j = 1
    while j <= length(Tab[i])
      if Tab[i,j] > x
        temp = x
        x = Tab[i,j]
        Tab[i][j] = temp
        i += 1
        break
      end
      j += 1
    end
  end
  push!(Tab.t,[x])
  return Tab
end

"""
    bump!(Tab::Tableau, x::Int, Q::Tableau, y::Int)

Inserts x into Tab according to the Bumping algorithm by applying the Schensted insertion.
Traces the change with Q by inserting y at the same Position (in Q) as x (in Tab).
"""
function bump!(Tab::Tableau, x::Integer, Q::Tableau, y::Integer)
  i = 1
  while i <= length(Tab)
    if Tab[i,length(Tab[i])] <= x
      push!(Tab[i], x)
      push!(Q[i], y)
      return Tab
    end
    j=1
    while j <= length(Tab[i])
      if Tab[i,j] > x
        temp = x
        x = Tab[i,j]
        Tab[i][j] = temp
        i += 1
        break
      end
      j += 1
    end
  end
  push!(Tab.t, [x])
  push!(Q.t, [y])

  return Tab,Q
end


"""
    is_standard(Tab::Tableau)

Checks if Tab is a standard Tableau. i.e. a Tableau with strictly increasing columns and rows, where each number from 1 to n appears exactly once.
"""
function is_standard(Tab::Tableau)
  #correct shape
  s = shape(Tab)
  for i = 1:length(s)-1
    if s[i] < s[i+1]
      return false
    end
  end

  #contains all numbers from 1 to n
  numbs = Array{Bool,1}(false,sum(s))
  for i = 1:length(s)
    for j = 1:s[i]
      numbs[Tab[i][j]] = true
    end
  end
  if false in numbs
    return false
  end

  #increasing first row
  for j = 2:length(s[1])
    if Tab[1][j] <= Tab[1][j-1]
      return false
    end
  end

  #increasing first column
  for i = 2:length(s)
    if Tab[i][1] <= Tab[i-1][1]
      return false
    end
  end

  #increasing rows and columns
  for i = 2:length(Tab)
    for j = 2:length(Tab[i])
      if Tab[i][j] <= Tab[i][j-1] || Tab[i][j] <= Tab[i-1][j]
        return false
      end
    end
  end
  return true
end


"""
    is_semistandard(Tab::Tableau)

Checks if Tab is a semistandard Tableau. i.e. a Tableau with non decresing rows and strictly increasing columns.
"""
function is_semistandard(Tab::Tableau)
  #correct shape
  s = shape(Tab)
  for i = 1:length(s)-1
    if s[i] < s[i+1]
      return false
    end
  end

  #increasing first row
  for j = 2:length(s[1])
    if Tab[i][j] < Tab[i][j-1]
      return false
    end
  end

  #increasing first column
  for i = 2:length(s)
    if Tab[i][1] <= Tab[i-1][1]
      return false
    end
  end

  #increasing rows and columns
  for i = 2:length(Tab)
    for j = 2:length(Tab[i])
      if Tab[i][j] < Tab[i][j-1] || Tab[i][j] <= Tab[i-1][j]
        return false
      end
    end
  end
  return true
end
