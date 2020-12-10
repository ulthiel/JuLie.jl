################################################################################
# Tableaux
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

import AbstractAlgebra: PolynomialRing, push_term!, MPolyBuildCtx, finish
import Nemo: ZZ, QQ, fmpz, fmpz_mpoly, fmpz_poly, addeq!, mul!, divexact , libflint

export Tableau, shape, semistandard_tableaux, is_standard, is_semistandard, schensted, hook_length, hook_length_formula, standard_tableaux, schur_polynomial, kostka_polynomial,reading_word, weight, charge

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
   semistandard_tableaux(s::Array{T,1}, weight::Array{T,1}) where T<:Integer

returns an Array containing all semistandard tableaux with shape s and weights weight.

requires that sum(s) == sum(weight)
"""
function semistandard_tableaux(s::Array{T,1}, weight::Array{T,1}) where T<:Integer
  n_max = sum(s)
  n_max==sum(weight) || throw(ArgumentError("sum(s) == sum(weight) required"))

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

returns an Array containing all semistandard tableaux with shape s and weights weight.

requires that sum(s) == sum(weight)
"""
function semistandard_tableaux(s::Partition{T}, weight::Partition{T}) where T<:Integer
  return semistandard_tableaux(Array{T,1}(s),Array{T,1}(weight))
end


"""
    standard_tableaux(s::Array{Integer,1})

returns a list of all standard young-Tableaux of a given shape s
"""
function standard_tableaux(s::Array{T,1}) where T<:Integer
  return standard_tableaux(Partition(s))
end


"""
    standard_tableaux(s::Partition)

returns a list of all standard young-Tableaux of a given shape s
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

returns a list of all standard young-Tableaux of size n
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


"""
    schensted(sigma::Array{Integer,1})

An implementation of the Schensted algorithm from the Robinson-Schensted correspondence.
sigma represents the second line of a Permutation in two-line notation:
1->sigma[1] , 2->sigma[2] , ...
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
    hook_length(Tab::Tableau, i::Integer, j::Integer)

returns the hook length of Tab[i][j].
assumes that Tab[i][j] exists
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

returns the hook length of Tab[i][j] for a Tableau Tab of shape s.
assumes that i<=length(s) and j<=s[i]
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

returns the hook length formula for a tableau of shape s.
Equals the number of standard tableaux of shape s
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
    schur_polynomial(shp::Partition)

returns the Schur function s_shp as a Multivariate Polynomial.
s_shp=sum_{SSYT of shape shp} x_1^{m1}...x_n^{m_n}
"""
function schur_polynomial(shp::Partition)
  num_boxes = sum(shp)
  x = [string("x",string(i)) for i=1:num_boxes]
  R,x = PolynomialRing(ZZ, x)

  sf = MPolyBuildCtx(R)

  #version of the function semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer)
  len = length(shp)
  Tab = [(fill(i,shp[i])) for i = 1:len]
  m = len
  n = shp[m]

  count = zeros(Int, num_boxes)

  while true
    count .= 0
    for i = 1:len
      for j = 1:shp[i]
        count[Tab[i][j]] += 1
      end
    end
    push_term!(sf, ZZ(1), count)

    #raise one element by 1
    while !(Tab[m][n] < num_boxes &&
      (n==shp[m] || Tab[m][n]<Tab[m][n+1]) &&
      (m==len || shp[m+1]<n || Tab[m][n]+1<Tab[m+1][n]))
      if n > 1
        n -= 1
      elseif m > 1
        m -= 1
        n = shp[m]
      else
        return finish(sf)
      end
    end

    Tab[m][n] += 1

    #minimize trailing elemnts
    if n < shp[m]
      i = m
      j = n + 1
    else
      i = m + 1
      j = 1
    end
    while (i<=len && j<=shp[i])
      if i == 1
        Tab[1][j] = Tab[1][j-1]
      elseif j == 1
        Tab[i][1] = Tab[i-1][1] + 1
      else
        Tab[i][j] = max(Tab[i][j-1], Tab[i-1][j] + 1)
      end
      if j < shp[i]
        j += 1
      else
        j = 1
        i += 1
      end
    end
    m = len
    n = shp[len]
  end #while
end


"""
    weight(Tab::Tableau)

returns the weight of the tableau Tab.
i.e. w::Array{Int,1} such that w[i] = number of appearances of i in Tab
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

"""
    charge(Tab::Tableau)

returns the charge of Tab.
"""
function charge(Tab::Tableau)
  return charge(reading_word(Tab))
end


"""
    charge(word::Array{Int,1},standard=false::Bool)

returns the charge of the Tableau corresponding to the reading word: word
"""
function charge(word::Array{Int,1},standard=false::Bool)
  c = 0
  if !standard
    baseword = copy(word)
    while length(baseword) > 0
      indices = Array{Int,1}()
      a = 1
      maxim = maximum(baseword)
      while a <= maxim
        emptyrun = true
        for i = length(baseword):-1:1
          if baseword[i] == a
            push!(indices,i)
            a += 1
            emptyrun = false
          end
        end
        if emptyrun
          a += 1
        end
      end
      sort!(indices)
      w = splice!(baseword,indices)
      c += charge(w,true)
    end
  else
    index = 0
    pointer = argmin(word)
    maxim = maximum(word)
    while word[pointer]!=maxim
      nextmin = word[pointer]+1
      while findfirst(==(nextmin),word) == nothing
        nextmin += 1
      end
      if findfirst(==(nextmin),word) > pointer
        index += 1
      end
      c += index
      pointer = findfirst(==(nextmin),word)
    end
  end
  return c

end


"""
    charge(config::Array{Partition{T},1})

returns the charge of an admissible configuration.
"""
function charge(config::Array{Partition{T},1}) where T<:Integer
  function M(p::Partition{T}, k::Partition{T})
    res=0
    for i in p
      for j in k
        if i>j
          res+=j
        else
          res+=i
        end
      end
    end
    return res
  end

  c=0
  #n[mu]
  for i=2:length(config[1])
    c+=(i-1)*config[1][i]
  end

  for k=2:length(config)
    c+=M(config[k],config[k])-M(config[k],config[k-1])   #first call of M(c,c) could be improved/specialized
  end
  return c
end


#= This function is obsolete. It got replaced by a faster function. But it could still be used to check the correctness of the new function, since they use different Algorithms
"""
    kostka_polynomial(lambda::Partition, mu::Partition)

returns the Kostka polynomial K_{lambda,mu} as a fmpz_poly over ZZ in t.
"""
function kostka_polynomial(lambda::Partition, mu::Partition)
  R,t = PolynomialRing(ZZ, "t")
  kos_poly = R()


  s = Array{Int,1}(lambda)
  weight = Array{Int,1}(mu)

  #= this is almost the same Algorithm used in semistandard_tableaux(s,weight)
  It is basically the following Algorithm:

  for Tab in semistandard_tableaux(lambda,mu)
    addeq!(kos_poly,t^charge(Tab))
  end

  =#
  n_max = sum(s)
  n_max==sum(weight) || throw(ArgumentError("sum(s) == sum(weight) required"))

  if isempty(s)
    return kos_poly
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
      addeq!(kos_poly,t^charge(Tab))    #this line is different from semistandard_tableaux(s,weight) - Algorithm
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

  return kos_poly

end
=#

"""
    kostka_polynomial(lambda::Partition{T}, mu::Partition{T})

returns the Kostka polynomial K_{lambda,mu} as a fmpz_poly over ZZ in t.

The Algorithm is based on https://inspirehep.net/files/ab8568896dcce9b3115b76dc9d096da4   A matrix model for WZW (Apendix B) by Nick Dorey, David Tonga and Carl Turner
"""
function kostka_polynomial(lambda::Partition{T}, mu::Partition{T}) where T<:Integer
  sum(lambda) == sum(mu) || throw(ArgumentError("lambda and mu have to be Partitions of the same Integer"))

  R,t = PolynomialRing(ZZ, "t")
  kos_poly = R()

  if length(lambda)==0 || !dominates(lambda,mu)
    return R()
  end

  #Here we apply fact 2.12 from https://arxiv.org/pdf/1608.01775.pdf  (AN ITERATIVE FORMULA FOR THE KOSTKA-FOULKES POLYNOMIALS - TIMOTHEE W. BRYAN AND NAIHUAN JING)
  copied = false
  i = 1
  while i<=length(lambda) && i<=length(mu) && lambda[i]==mu[i]
    i += 1
  end
  if i != 1
    if lambda == mu
      return R(1)
    end
    lambda_copy = copy(lambda)
    mu_copy = copy(mu)
    lambda = Partition{T}(lambda[i:end])
    mu = Partition{T}(mu[i:end])
    copied = true
  end

  len_lam = length(lambda) #note that length(v)=Length(lambda)
  len_mu = length(mu)

  #calculate the sizes of the partitions from the admissible configurations
  size_v = Partition{T}(zeros(T,len_lam))
  for k = 1:len_lam
    for j = k:len_lam
      size_v[k] += lambda[j]
    end
  end

  #compute the Arrays of available Partitions
  parts = Array{Array{Partition{T},1},1}([[] for i = 1:len_lam])
  for i = 2:len_lam
    parts[i] = partitions(size_v[i])
  end
  parts[1] = [mu]


  index_max = [length(parts[i]) for i=1:len_lam] #gives an upper bound to how big index can get
  index = ones(Int, len_lam)  #will be our itterator with which we will look at all admissible configurations
  empty_partition = Partition{T}([])  #this will act as a placeholder during the Algorithm
  pointer = 2  #this will index the part of the configuration we are currently looking at
  v = Array{Partition{T},1}([empty_partition for i=1:len_lam])
  v[1] = mu

  #returns P_n^(k)
  function vacancy(n,k)
    res = 0

    for vj in v[k-1]
      res += min(n,vj)
    end

    if k < len_lam
      for vj in v[k+1]
        res += min(n,vj)
      end
    end

    for vj in v[k]
      res -= 2*min(n,vj)
    end

    return res
  end

  #Here the actual Algorithm begins
  while pointer > 1

    if pointer == len_lam + 1
      summand = t^charge(v)
      for k = 2:len_lam
        m = partition_to_partcount(v[k])
        for n = 1:length(m)
          P_nk = vacancy(n,k)
          if P_nk > 0
            #multiply by the q-binomial coefficient
            high = P_nk + m[n]
            for i = 0:m[n] - 1
              mul!(summand, summand, (1-t^(high-i)))
              summand = divexact(summand, (1-t^(i+1)))
            end
          end
        end
      end
      addeq!(kos_poly, summand)
      pointer -= 1
      index[pointer] += 1

    else
      if index[pointer] > index_max[pointer]
        v[pointer] = empty_partition
        pointer -= 1
        index[pointer] += 1
      else
        v[pointer] = parts[pointer][index[pointer]]
        n = 1
        if pointer > 2
          max_n = max(v[pointer-2][1], v[pointer-1][1], v[pointer][1])
        else
          max_n = max(v[pointer-1][1], v[pointer][1])
        end
        while n <= max_n
          if pointer > 2 && vacancy(n,pointer-1) < 0 || vacancy(n,pointer) < -getelement(size_v,pointer+1)
            index[pointer] += 1
            if index[pointer] > index_max[pointer]
              break
            else
              v[pointer] = parts[pointer][index[pointer]]
              if max_n < v[pointer][1]
                max_n = v[pointer][1]
              end
            end
            n = 0
          end
          n += 1
        end
        if n == max_n + 1
          pointer += 1
          if pointer <= len_lam
            index[pointer] = 1
          end
        end
      end
    end
  end

  if copied
    lambda = lambda_copy
    mu = mu_copy
  end

  return kos_poly
end
