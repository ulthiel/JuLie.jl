################################################################################
# Kostka Polynomials
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

#import AbstractAlgebra: PolynomialRing
import Nemo: ZZ, fmpz, fmpz_poly, addeq!, mul!, divexact , libflint

export kostka_polynomial, charge


"""
    kostka_polynomial(lambda::Partition{T}, mu::Partition{T})

The (one-variable) **Kostka polymial** ``K_{λμ}(t)`` associated to partitions λ and μ can be defined as

```math
K_{λμ}(t) = ∑_{T ∈ SSYT(λ,μ)} t^{charge(T)} ∈ ℕ[t]  \\;,
```

where SSYT(λ,μ) is the set of all semistandard Young tableaux of shape λ and weight μ, and charge(T) is the charge of the tableau T. The Kostka polynomials relate the Hall–Littlewood polynomials ``P_μ``
to the Schur polynomials ``s_λ`` via
```math
s_λ(x_1,…,x_n) = \\sum_μ K_{λμ}(t)P_μ(x_1,…,x_n;t)
```
This function returns the Kostka polynomial ``K_{λμ}(t)`` as an fmpz_poly over ZZ in t.

# Example
```julia-repl
julia> kostka_polynomial([4,2,1],[3,2,1,1])
t^3 + 2*t^2 + t
```

# Algorithm
The computation here is not based on the above formula but on an explicit description due to Kirillov–Reshetikhin in "The Bethe ansatz and the combinatorics of Young tableaux", J. Sov. Math. 41 (1988) 925., which is summarized by Dorey–Tonga–Turner in "[A matrix model for WZW](https://inspirehep.net/files/ab8568896dcce9b3115b76dc9d096da4)" (Apendix B). Namely:

```math
K_{λ,μ}(t)=∑_{\\{v\\}}∏_{K=1}^{l(λ)-1}∏_{n≥1}
\\begin{bmatrix}
ℙ_n^{(K)}+m_n(v^{(K)})\\\\
m_n(v^{(K)})
\\end{bmatrix}_t \\;,
```

where the sum is over all admissible configurations ``\\{v\\}`` i.e. sequences of partitions ``v^{(K)}`` with

```math
v^{(0)}=μ \\text{ ,\\hspace{2mm} } |v^{(K)}|=∑_{j≥K+1}λ_j \\text{\\hspace{5mm} and \\hspace{5mm}} ℙ_n^{(K)}≥0  \\text{\\hspace{2mm} for all \\hspace{1mm}} n>0, K=0,1,…l(λ)
```

```math
\\begin{aligned}
& ℙ_n^{(K)} := ∑_{j≥1}\\left[\\min\\left(n,v_j^{(K+1)}\\right) - 2⋅\\min\\left(n,v_j^{(K)}\\right) + \\min\\left(n,v_j^{(K-1)}\\right)\\right]
\\\\
& c(v) := ∑_{i≥1}(i-1)μ_i + ∑_{K=1}^{l(λ)-1}\\left(𝕄\\left[v^{(K)}, v^{(K)}\\right] - 𝕄\\left[v^{(K)}, v^{(K-1)}\\right]\\right)
\\\\
& 𝕄[ρ,κ] := ∑_{i,j≥1} \\min(ρ_i,κ_j)
\\end{aligned}
```

Here, ``\\left[\\genfrac{[}{]}{0pt}{0}{m}{n} \\right]_t`` is the [Gaussian binomial coefficient](https://en.wikipedia.org/wiki/Gaussian_binomial_coefficient).
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
  index = ones(Int, len_lam)  #will be our iterator with which we will look at all admissible configurations
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
          if m[n] > 0
            P_nk = vacancy(n,k)
            if P_nk > 0
              #multiply by the q-binomial coefficient [P_nk+m[n] ; m[n]]
              high = P_nk + m[n]
              for i = 0:m[n] - 1
                mul!(summand, summand, (1-t^(high-i)))
                summand = divexact(summand, (1-t^(i+1)))
              end
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


"""
    kostka_polynomial(lambda::Array{Integer,1}, mu::Array{Integer,1})

Shortcut for ```kostka_polynomial```.
"""
function kostka_polynomial(lambda::Array{Int,1}, mu::Array{Int,1})
   return kostka_polynomial(Partition(lambda), Partition(mu))
end


"""
    charge(config::Array{Partition{T},1})

returns the charge of an admissible configuration ``config``.
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



"""
    charge(Tab::Tableau)

returns the charge of ``Tab``.
"""
function charge(Tab::Tableau)
  return charge(reading_word(Tab))
end


"""
    charge(word::Array{Int,1},standard=false::Bool)

returns the charge of the Tableau corresponding to the reading word ``word``
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
