################################################################################
# Schur Polynomials
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

import AbstractAlgebra: PolynomialRing, push_term!, MPolyBuildCtx, finish, MatrixSpace
import Nemo: ZZ, fmpz, fmpz_mpoly, FmpzMPolyRing, gens, divexact, mul!

export schur_polynomial


"""
    schur_polynomial(λ::Partition)
    schur_polynomial(λ::Partition{T}, R::FmpzMPolyRing) where T<:Integer

Returns the Schur polynomial ``s_λ`` in sum(λ) variables, as a Multivariate Polynomial:

```math
s_λ:=∑_T x₁^{m₁}…xₙ^{mₙ}
```

where the sum is taken over all semistandard [`tableaux`](@ref JuLie.Tableau) ``T`` of shape ``λ``, and ``mᵢ`` gives the weight of ``i`` in ``T``.
"""
function schur_polynomial(λ::Partition{T}, R::FmpzMPolyRing) where T<:Integer
  if isempty(λ)
    return one(R)
  end
  num_boxes = sum(λ)
  x = gens(R)
  S = R.base_ring

  sf = MPolyBuildCtx(R)

  #version of the function semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer)
  len = length(λ)
  Tab = [(fill(i,λ[i])) for i = 1:len]
  m = len
  n = λ[m]

  count = zeros(Int, length(x))

  while true
    count .= 0
    for i = 1:len
      for j = 1:λ[i]
        count[Tab[i][j]] += 1
      end
    end
    push_term!(sf, S(1), count)
    #raise one element by 1
    while !(Tab[m][n] < num_boxes &&
      (n==λ[m] || Tab[m][n]<Tab[m][n+1]) &&
      (m==len || λ[m+1]<n || Tab[m][n]+1<Tab[m+1][n]))
      if n > 1
        n -= 1
      elseif m > 1
        m -= 1
        n = λ[m]
      else
        return finish(sf)
      end
    end

    Tab[m][n] += 1

    #minimize trailing elements
    if n < λ[m]
      i = m
      j = n + 1
    else
      i = m + 1
      j = 1
    end
    while (i<=len && j<=λ[i])
      if i == 1
        Tab[1][j] = Tab[1][j-1]
      elseif j == 1
        Tab[i][1] = Tab[i-1][1] + 1
      else
        Tab[i][j] = max(Tab[i][j-1], Tab[i-1][j] + 1)
      end
      if j < λ[i]
        j += 1
      else
        j = 1
        i += 1
      end
    end
    m = len
    n = λ[len]
  end #while
end

function schur_polynomial(λ::Partition{T}) where T<:Integer
  if isempty(λ)
    return ZZ(1)
  end
  x = [string("x",string(i)) for i=1:sum(λ)]
  R,x = PolynomialRing(ZZ, x)
  return schur_polynomial(λ, R)
end


"""
    schur_polynomial(λ::Partition{T}, n::Integer) where T<:Integer

Returns the Schur polynomial ``s_λ(x₁,x₂,...,xₙ)`` over `PolynomialRing(ZZ,["x1","x2",...,"xn"])`.

If ``sum(λ) = n`` consider calling `schur_polynomial(λ)` instead; this tends to be much faster.
"""
function schur_polynomial(λ::Partition{T}, n::Integer) where T<:Integer
  n>=0 || throw(ArgumentError("n≥0 required"))
  x = [string("x",string(i)) for i=1:n]
  R,x = PolynomialRing(ZZ, x)
  return schur_polynomial(λ, x)
end


"""
    schur_polynomial(λ::Partition{T}, x::Array{fmpz_mpoly,1}) where T<:Integer

Returns the Schur polynomial of `λ` in the variables from `x`: ``s_λ(x[1],x[2],...,x[n])``.

If ``x`` are the generators of `R`, and ``sum(λ) = length(x)`` consider calling `schur_polynomial(λ, R)` instead; this tends to be much faster.

# Example
```julia-repl
julia> schur_polynomial(Partition([3,2,1]),[x1,x2])
x1^3*x2^2 + x1^2*x2^3
```

# Algorithm
We use *Cauchy's bialternant formula* to compute the Schur polynomials in `x`:

```math
s_λ(x₁,…,xₙ) =  ∏_{1 ≤ i < j ≤ n} (x_i-x_j)^{-1} ⋅
\\begin{vmatrix}
x_1^{λ₁+n-1} & x_2^{λ_1+n-1} & … & x_n^{λ_1+n-1} \\\\
x_1^{λ_2+n-2} & x_2^{λ_2+n-2} & … & x_n^{λ_2+n-2} \\\\
⋮ & ⋮ & ⋱ & ⋮ \\\\
x_1^{λ_n} & x_2^{λ_n} & … & x_n^{λ_n}
\\end{vmatrix}
```
"""
function schur_polynomial(λ::Partition{T}, x::Array{fmpz_mpoly,1}) where T<:Integer
#**Note** : This Algorithm could be improved for some cases, by calling schur_polynomial(λ) and then deleting the Terms that aren't over x.
  if isempty(x)
    if sum(λ)==0
      return 1
    else
      return 0
    end
  end

  n = length(x)
  R = x[1].parent # Multi-polynomialring
  S = R.base_ring # Integer Ring

  #=
  To calculate the determinant we use the Laplace expansion along the last row.
  Furthermore we use the fact, that each column consist of the same variable with decreasing powers.
  This allows us to factorize by the smallest power, thus our last row of the minors is always 1, this reduces the amount of polynomial multiplications we have to do.

  To avoid calculating the same minors multiple times, we calculate them from 1x1 up to nxn, always storing them in a Dictionary.
  Keep in mind that each minor consists of k columns and the top k rows.
  =#

  #initializing a few helpful Variables
  exponents = Int[getelement(λ,i)+n-i for i=1:n] #the exponents from the Matrix read from top to bottom
  exp_incr = zeros(Int,n) #the increment with wich exponents increase
  for i = 1:n-1
    exp_incr[i] = exponents[i] - exponents[i+1]
  end
  exp_incr[n] = exponents[n]

  factor = one(R)
  d = R()

  #Initialize Dictionaries (calculating all possible combinations of k=1...n columns)
  sub_dets = [Dict{BitArray{1},fmpz_mpoly}() for i=1:n] #sub_dets[i] holds all the minors of size i, i.e. sub_dets[2][[false,true,true,false,false]] is the minor of the 2x2 matrix consisting of the first two rows intersected with the 2nd and 3rd columns.
  b = falses(n)
  ntrues = 0
  pointer = 1
  while true
    if b[pointer]
      while pointer<=n && b[pointer]
        b[pointer] = false
        ntrues -= 1
        pointer += 1
      end
      if pointer>n
        break
      end
    end
    b[pointer] = true
    ntrues += 1
    pointer = 1
    sub_dets[ntrues][copy(b)] = R()
  end

  #initialize sub_dets[1]
  for (columnview,) in sub_dets[1]
    sub_dets[1][columnview] = x[columnview][1]^(exp_incr[1])
  end

  #calculate sub_dets[2:n] using Laplace extension
  exp = zeros(Int,n)
  for i = 2:n
    for (columnview,) in sub_dets[i]
      d = R() #the alternating sum of minors
      s = ((i+n)%2==1 ? 1 : -1) #the alternating sign
      for j in (1:n)[columnview]
        columnview[j] = false
        d += s*sub_dets[i-1][columnview]
        columnview[j] = true
        s *= -1 #change sign
      end

      #multiply by the factorized term
      factor = MPolyBuildCtx(R)
      exp = zeros(Int,n)
      exp[columnview] .= exp_incr[i]
      push_term!(factor, one(S), exp)
      sub_dets[i][columnview] = mul!(d, d, finish(factor))
    end
  end
  sp = sub_dets[n][trues(n)]

  # divide by the product
  for i = 1:n-1
    for j = i+1:n
      sp = divexact(sp, x[i]-x[j])
    end
  end

  return sp
end
