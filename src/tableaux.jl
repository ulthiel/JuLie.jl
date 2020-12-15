################################################################################
# Tableaux
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export Tableau, shape, semistandard_tableaux, is_standard, is_semistandard, schensted, hook_length, hook_length_formula, standard_tableaux, reading_word, weight


"""
    struct Tableau{T} <: AbstractArray{AbstractArray{T,1},1}

A **tableau** or Young tableau is a finite collection of boxes, each holding a value. The boxes are arranged in left-justified rows. These rows are read from top to bottom. The row lengths have to be non-increasing order.
You can create a tableau with
```
Tab=Tableau([[1,2,3],[4,5],[6]])
```
and then work with it like with an array of arrays. In fact, Tableau is a subtype of  AbstractArray{AbstractArray{T,1},1}.
Note that for efficiency the Tableau constructor does not check whether the given array is in fact a Tableau, i.e. a sequence of Arrays with decreasing lenghts. That's your job.
The implementation of a subtype of AbstractArray is explained in [the Julia documentation](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).

Furthermore there are two spezial types of tableaux:

A **semistandard tableaux** is a tableaux where the values are non decreasing in each row, and strictly increasing in each column.

A **standard tableaux** is a tableaux where the values are strictly increasing in each row and column. A standard tableaux also requires each Integer from 1 to the amount of boxes to occur exactly once.
"""
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

"""
    shape(Tab::Tableau{T})

returns the shape of ``Tab`` as a Partition

The **shape** of a Tableau describes the length of each row. i.e:
```
julia> shape([ [1,2,3,4], [5,6], [7] ])
  [4, 2, 1]
```
"""
function shape(Tab::Tableau{T}) where T
  return Partition{T}([ length(Tab[i]) for i=1:length(Tab) ])
end


"""
    semistandard_tableaux(shape::Partition{T}, max_val=sum(shape)::Integer) where T<:Integer

returns an Array containing all **semistandard tableaux** of shape ``shape`` and elements `` ≤ max\\_val``.
The tableaux are in lexicographic order from left to right and top to bottom.
"""
function semistandard_tableaux(shape::Partition{T}, max_val=sum(shape)::T) where T<:Integer
  return semistandard_tableaux(Array{T,1}(shape), max_val)
end


"""
    semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer) where T<:Integer

returns an Array containing all **semistandard tableaux** of shape ``shape`` and elements `` ≤ max\\_val``.
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
    push!(SST,Tableau([copy(row) for row in Tab]))

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

returns an Array containing all **semistandard tableaux** made from ``box\\_num`` boxes and elements `` ≤ max\\_val``.
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
    semistandard_tableaux(s::Array{T,1}, weight::Array{T,1}) where T<:Integer

returns an Array containing all **semistandard tableaux** with shape ``s`` and weights ``weight``.

requires that ``sum(s) = sum(weight)``
"""
function semistandard_tableaux(s::Array{T,1}, weight::Array{T,1}) where T<:Integer
  n_max = sum(s)
  n_max==sum(weight) || throw(ArgumentError("sum(s) = sum(weight) required"))

  Tabs = Array{Tableau,1}()
  if isempty(s)
    push!(Tabs, Tableau([[]]))
    return Tabs
  end
  ls = length(s)

  Tab = Tableau([ [0 for j = 1:s[i]] for i = 1:length(s)])
  sub_s = zeros(Integer, length(s))

  #tracker_row = zeros(Integer,n_max)

  function rec_sst!(n::Integer)

    #fill the remaining boxes if possible, else set them to 0
    if n == length(weight)
      for i = 1:ls
        for j = sub_s[i]+1:s[i]
          Tab[i][j] = n
          if i!=1 && Tab[i-1][j]==n
            for k = 1:i
              for l = sub_s[k]+1:s[k]
                Tab[i][j] = 0
              end
            end
            return
          end
        end
      end
      push!(Tabs,Tableau([copy(row) for row in Tab]))

      return
    #skip to next step if weight[n]==0
    elseif weight[n] == 0
      rec_sst!(n+1)
      return
    end
    #here starts the main part of the function
    tracker_row = zeros(Integer, weight[n])
    i = 1
    while sub_s[i] == s[i]
      i += 1
    end
    j = sub_s[i] + 1

    m=0
    while m >= 0
      if m == weight[n]         #jump to next recursive step
        rec_sst!(n+1)
        Tab[tracker_row[m]][sub_s[tracker_row[m]]] = 0
        i = tracker_row[m] + 1
        if i <= ls
          j = sub_s[i] + 1
        end
        m -= 1
        sub_s[i-1] -= 1

      elseif i > ls
        if m == 0
          return
        else
          Tab[tracker_row[m]][sub_s[tracker_row[m]]] = 0
          i = tracker_row[m] + 1
          if i <= ls
            j = sub_s[i] + 1
          end
          m -= 1
          sub_s[i-1] -= 1
        end

      elseif j<=s[i] && (i==1 || (j<=sub_s[i-1] && n>Tab[i-1][j]))  #add an entry
        m += 1
        Tab[i][j] = n
        sub_s[i] += 1
        tracker_row[m] = i
        j += 1

      else              #move pointerhead
        i += 1
        if i <= ls
          j = sub_s[i] + 1
        end
      end
    end  #while
  end  #rec_sst!()

  rec_sst!(1)
  return Tabs
end


"""
    semistandard_tableaux(s::Partition{T}, weight::Partition{T}) where T<:Integer

returns an Array containing all **semistandard tableaux** with shape ``s`` and weights ``weight``.

requires that ``sum(s) = sum(weight)``
"""
function semistandard_tableaux(s::Partition{T}, weight::Partition{T}) where T<:Integer
  return semistandard_tableaux(Array{T,1}(s),Array{T,1}(weight))
end


"""
    standard_tableaux(s::Array{Integer,1})

returns a list of all **standard tableaux** of a given shape ``s``
"""
function standard_tableaux(s::Array{T,1}) where T<:Integer
  return standard_tableaux(Partition(s))
end


"""
    standard_tableaux(s::Partition)

returns a list of all **standard tableaux** of a given shape ``s``
"""
function standard_tableaux(s::Partition)
  Tabs = Array{Tableau,1}()
  if isempty(s)
    push!(Tabs, Tableau([[]]))
    return Tabs
  end
  n_max = sum(s)
  ls = length(s)

  Tab = Tableau([ [0 for j = 1:s[i]] for i = 1:length(s)])
  sub_s = [0 for i=1:length(s)]
  Tab[1][1] = 1
  sub_s[1] = 1
  tracker_row = [0 for i=1:n_max]
  tracker_row[1] = 1

  n = 1
  i = 1
  j = 2

  while n > 0
    if n == n_max || i > ls
      if n == n_max
        push!(Tabs,Tableau([copy(row) for row in Tab]))
      end
      Tab[tracker_row[n]][sub_s[tracker_row[n]]] = 0
      i = tracker_row[n] + 1
      if i <= ls
        j = sub_s[i] + 1
      end
      n -= 1
      sub_s[i-1] -= 1
    elseif j<=s[i] && (i==1 || j<=sub_s[i-1])
      n += 1
      Tab[i][j] = n
      sub_s[i] += 1
      tracker_row[n] = i
      i = 1
      j = sub_s[1] + 1
    else
      i += 1
      if i <= ls
        j = sub_s[i] + 1
      end
    end
  end

  return Tabs
end


"""
    standard_tableaux(n::Integer)

returns a list of all **standard tableaux** of size ``n``
"""
function standard_tableaux(n::Integer)
  ST = Array{Tableau,1}()
  for s in partitions(n)
    append!(ST, standard_tableaux(s))
  end
  return ST
end


"""
    is_standard(Tab::Tableau)

Checks if ``Tab`` is a **standard tableau**. i.e. a Tableau with strictly increasing columns and rows, where each number from 1 to n appears exactly once.
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
  numbs = falses(sum(s))
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

Checks if ``Tab`` is a **semistandard tableau**. i.e. a Tableau with non decresing rows and strictly increasing columns.
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


"""
    schensted(sigma::Array{Integer,1})

An implementation of the Schensted algorithm from the Robinson-Schensted correspondence.
``sigma`` represents the second line of a Permutation in two-line notation:
``1->sigma[1] , 2->sigma[2] ,…``
Returns a pair of **standard tableaux** ``P,Q`` (insertion- and recording- tableaux)
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
    bump!(Tab::Tableau, x::Int)

Inserts ``x`` into ``Tab`` according to the [Bumping algorithm](https://mathworld.wolfram.com/BumpingAlgorithm.html) by applying the Schensted insertion.
"""
function bump!(Tab::Tableau, x::Integer)
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
    bump!(Tab::Tableau, x::Integer, Q::Tableau, y::Integer)

Inserts ``x`` into ``Tab`` according to the [Bumping algorithm](https://mathworld.wolfram.com/BumpingAlgorithm.html) by applying the Schensted insertion.
Traces the change with ``Q`` by inserting ``y`` at the same Position in ``Q`` as ``x`` in ``Tab``.
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
    hook_length(Tab::Tableau, i::Integer, j::Integer)

returns the **hook length** of ``Tab[i][j]``.

The **hook length** of a cell, is the count of cells to the right in the same row + the count of cells below in the same column + 1

assumes that ``Tab[i][j]`` exists
"""
function hook_length(Tab::Tableau, i::Integer, j::Integer)
  s = shape(Tab)
  h = s[i] - j + 1
  k = j + 1
  while k<=length(s) && s[k]>=j
    k += 1
    h += 1
  end
  return h
end


"""
    hook_length(s::Partition, i::Integer, j::Integer)

returns the **hook length** of ``Tab[i][j]`` for a Tableau ``Tab`` of shape ``s``.

assumes that ``i≤length(s)`` and ``j≤s[i]``
"""
function hook_length(s::Partition, i::Integer, j::Integer)
  h = s[i] - j + 1
  k = i + 1
  while k<=length(s) && s[k]>=j
    k += 1
    h += 1
  end
  return h
end


"""
    hook_length_formula(s::Partition)

returns the **hook length formula** for a tableau of shape ``s``.

```math
f^{λ} = {\\dfrac{n!}{∏ h_λ(i,j)}}
```
where the product is over all cells ``(i,j)`` in ``Tab``, and ``h_λ`` is the [hook_length](index.html#JuLie.hook_length).

Equals the number of standard tableaux of shape ``s``
"""
function hook_length_formula(s::Partition)
  h=factorial(big(sum(s)))
  for i = 1:length(s)
    for j = 1:s[i]
      h=Integer(h/hook_length(s,i,j))
    end
  end
  return h
end


"""
    weight(Tab::Tableau)

returns the **weight** of the tableau ``Tab``.

i.e. ``w``::Array{Int,1} such that ``w[i]`` = number of appearances of ``i`` in ``Tab``
"""
function weight(Tab::Tableau)
  max=0
  for i=1:length(Tab)
    if max<Tab[i][end]
      max=Tab[i][end]
    end
  end

  w = zeros(Int,max)
  for rows in Tab
    for box in rows
      w[box] += 1
    end
  end
  return w
end


"""
    reading_word(Tab::Tableau)

returns an Array containing the cells of ``Tab`` read from left to right and from bottom to top.

```
julia> reading_word([ [1,2,3] , [4,5] , [6] ])
6-element Array{Int64,1}:
 6
 4
 5
 1
 2
 3
```
"""
function reading_word(Tab::Tableau)
  w=zeros(Int,sum(shape(Tab)))
  k=0
  for i = length(Tab):-1:1
    for j = 1:length(Tab[i])
      k += 1
      w[k] = Tab[i,j]
    end
  end
  return w
end
