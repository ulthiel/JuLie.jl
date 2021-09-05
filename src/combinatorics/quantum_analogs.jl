################################################################################
# Quantum analogs
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export quantum_integer, quantum_factorial, quantum_binomial

@doc raw"""
	quantum_integer(n::Int, q::RingElem)

Let ``n ∈ ℤ`` and let ``ℚ(𝐪)`` be the fraction field of the polynomial ring ``ℤ[𝐪]``. The **quantum integer** ``[n]_𝐪 ∈ ℚ(𝐪)`` of ``n`` is defined as
```math
[n]_𝐪 ≔ \frac{𝐪^n-1}{𝐪-1} \;.
```
We have
```math
[n]_𝐪 = \sum_{i=0}^{n-1} 𝐪^i ∈ ℤ[𝐪] \quad \text{if } n ≥ 0
```
and
```math
[n]_𝐪 = -𝐪^{n} [-n]_𝐪 \quad \text{for any } n ∈ ℤ \;,
```
hence
```math
[n]_𝐪 = - \sum_{i=0}^{-n-1} 𝐪^{n+i} ∈ ℤ[𝐪^{-1}] \quad \text{ if } n < 0 \;.
```
This shows in particular that actually
```math
[n]_𝐪 ∈ ℤ[𝐪,𝐪^{-1}] ⊂ ℚ(𝐪) \quad \text{ for any } n ∈ ℤ \;.
```
Now, for an element ``q`` of a ring ``R`` we define ``[n]_q ∈ R`` as the specialization of ``[n]_𝐪`` in ``q`` using the two equations above—assuming that ``q`` is invertible in ``R`` if ``n<0``. Note that for ``q=1`` we obtain
```math
[n]_1 = n \quad \text{for for any } n ∈ ℤ \;,
```
so the quantum integers are "deformations" of the usual integers.

If the argument ``q`` is not specified, then ``[n]_𝐪`` is returned as an element of ``ℤ[𝐪,𝐪^{-1}]``. If ``q`` is a Julia integer, then it is taken as an element of ```ZZ``` if ``n ≥ 0`` or ``q = ± 1``, otherwise it is taken as an element of ```QQ```.

# Examples
```julia-repl
julia> quantum_integer(3)
q^2 + q + 1
julia> quantum_integer(-3)
-q^-1 - q^-2 - q^-3
julia> quantum_integer(-3,2)
-7//8
```

# References
1. Conrad, K. (2000). A q-analogue of Mahler expansions. I. *Adv. Math., 153*(2), 185--230. [https://doi.org/10.1006/aima.1999.1890](https://doi.org/10.1006/aima.1999.1890)
2. Kac, V. & Cheung, P. (2002). *Quantum calculus*. Springer-Verlag, New York.
3. Wikipedia, [Q-analog](https://en.wikipedia.org/wiki/Q-analog).
"""
function quantum_integer(n::Int, q::RingElem)

	R = parent(q)
	if isone(q)
		return R(n)
	else
		z = zero(R)
		if n >= 0
			for i=0:n-1
				z += q^i
			end
		else
			for i=0:-n-1
				z -= q^(n+i)
			end
		end
		return z
	end
end

function quantum_integer(n::Int, q::Int)
	if n >= 0 || q == 1 || q == -1
		return quantum_integer(n,ZZ(q))
	else
		return quantum_integer(n,QQ(q))
	end
end

function quantum_integer(n::Int)
	R,q = LaurentPolynomialRing(ZZ, "q")
	return quantum_integer(n,q)
end


@doc raw"""
	quantum_factorial(n::Int, q::RingElem)

For a non-negative integer ``n`` and an element ``q`` of a ring ``R`` the **quantum factorial** ``[n]_q! ∈ R`` is defined as
```math
[n]_q! ≔ [1]_q ⋅ … ⋅ [n]_q ∈ R \;.
```
Note that for ``q=1`` we obtain
```math
[n]_1! = n! \quad \text{ for all } n ∈ ℤ \;,
```
hence the quantum factorial is a "deformation" of the usual factorial.

# Examples
```julia-repl
julia> quantum_factorial(3)
q^3 + 2*q^2 + 2*q + 1
```
"""
function quantum_factorial(n::Int, q::RingElem)

	n >= 0 || throw(ArgumentError("n ≥ 0 required"))

	R = parent(q)
	if isone(q)
		return R(factorial(n))
	else
		z = one(R)
		for i=1:n
			z *= quantum_integer(i,q)
		end
		return z
	end
end

function quantum_factorial(n::Int, q::Int)
	return quantum_factorial(n,ZZ(q))
end

function quantum_factorial(n::Int)
	R,q = LaurentPolynomialRing(ZZ, "q")
	return quantum_factorial(n,q)
end

@doc raw"""
	quantum_binomial(n::Int, q::RingElem)

Let ``k`` be a non-negative integer and let ``n ∈ ℤ``. The **quantum binomial** ``\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 \in ℚ(𝐪)`` is defined as
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 ≔ \frac{[n]_𝐪!}{[k]_𝐪! [n-k]_𝐪!} = \frac{[n]_𝐪 [n-1]_𝐪⋅ … ⋅ [n-k+1]_𝐪}{[k]_𝐪!}
```
Note that the first expression is only defined for ``n ≥ k`` since the quantum factorials are only defined for non-negative integers—but the second  expression is well-defined for all ``n ∈ ℤ`` and is used for the definition. In Corad (2000) it is shown that
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 = \sum_{i=0}^{n-k} q^i \begin{bmatrix} i+k-1 \\ k-1 \end{bmatrix}_𝐪 \quad \text{if } n ≥ k > 0 \;.
```
Since
```math
\begin{bmatrix} n \\ 0 \end{bmatrix}_𝐪 = 1 \quad \text{for all } n ∈ ℤ
```
and
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 = 0 \quad \text{if } 0 ≤ n < k \;,
```
it follows inductively that
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 ∈ ℤ[𝐪] \quad \text{if } n ≥ 0 \;.
```
For all ``n ∈ ℤ`` we have the relation
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 = (-1)^k 𝐪^{-k(k-1)/2+kn} \begin{bmatrix} k-n-1 \\ k \end{bmatrix}_𝐪 \;,
```
which shows that
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 ∈ ℤ[𝐪^{-1}] \quad \text{if } n < 0 \;.
```
In particular,
```math
\begin{bmatrix} n \\ k \end{bmatrix}_𝐪 ∈ ℤ[𝐪,𝐪^{-1}] \quad \text{for all } n ∈ ℤ \;.
```
Now, for an element ``q`` of a ring ``R`` we define ``\begin{bmatrix} n \\ k \end{bmatrix}_q`` as the specialization of ``\begin{bmatrix} n \\ k \end{bmatrix}_{\mathbf{q}}`` in ``q``, where ``q`` is assumed to be invertible in ``R`` if ``n < 0``.

Note that for ``q=1`` we obtain
```math
\begin{bmatrix} n \\ k \end{bmatrix}_1 = {n \choose k} \;,
```
hence the quantum binomial coefficient is a "deformation" of the usual binomial coefficient.

# Examples
```julia-repl
julia> quantum_binomial(4,2)
q^4 + q^3 + 2*q^2 + q + 1
julia> quantum_binomial(19,5,-1)
36
julia> K,i = CyclotomicField(4);
julia> quantum_binomial(17,10,i)
0
```

# References
1. Conrad, K. (2000). A q-analogue of Mahler expansions. I. *Adv. Math., 153*(2), 185--230. [https://doi.org/10.1006/aima.1999.1890](https://doi.org/10.1006/aima.1999.1890)
2. Wikipedia, [Gaussian binomial coefficient](https://en.wikipedia.org/wiki/Gaussian_binomial_coefficient)
"""
function quantum_binomial(n::Int, k::Int, q::RingElem)

	k >= 0 || throw(ArgumentError("k ≥ 0 required"))

	R = parent(q)
	if isone(q)
		return R(binomial(n,k))
	elseif k == 0
		return one(R)
	elseif k == 1
		return quantum_integer(n,q)
	elseif n >= 0
		if n < k
			return zero(R)
		else
			z = zero(R)
			for i=0:n-k
				z += q^i * quantum_binomial(i+k-1,k-1,q)
			end
			return z
		end
	elseif n<0
		return (-1)^k * q^(div(-k*(k-1),2) + k*n) * quantum_binomial(k-n-1,k,q)
	end

end

function quantum_binomial(n::Int, k::Int, q::Int)
	if n > 0
		return quantum_binomial(n,k,ZZ(q))
	else
		return quantum_binomial(n,k,QQ(q))
	end
end

function quantum_binomial(n::Int, k::Int)
	R,q = LaurentPolynomialRing(ZZ, "q")
	return quantum_binomial(n,k,q)
end
