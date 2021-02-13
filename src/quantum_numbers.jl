################################################################################
# Quantum numbers
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

export quantum, quantum_number, gaussian_binomial



"""
	quantum_number(n::Int, q::RingElem)

For an integer n ≥ 0 and an invertible element q of a ring R, the quantum integer ``[n]_q \\in R`` is for n ≥ 0 defined as ``[n]_q = \\sum_{i=0}^{n-1} q^{n-(2i+1)}`` and for n < 0 as ``[n]_q = -[-n]_q``.
"""
function quantum_number(n::Int, q::RingElem)

	R = parent(q)
	if isone(q)
		return R(n)
	else
		if n >= 0
			z = zero(R)
			for i=0:n-1
				z += q^(n-(2*i+1))
			end
			return z
		else
			return -quantum(-n, q)
		end
	end

end

"""
	quantum(n::Int, q::RingElem)

This is a shortcut for ```quantum_number(n,q)```.

"""
function quantum(n::Int, q::RingElem)
	return quantum_number(n,q)
end

"""
	quantum_number(n::Int)

The quantum number ``[n]_q`` where q is the indeterminate of the Laurent polynomial ring ``\\mathbb{Z}[q,q^{-1}]`` in one variable over the integers.
"""
function quantum_number(n::Int)
	R,q = LaurentPolynomialRing(ZZ, "q")
	return quantum_number(n,q)
end

"""
	quantum(n::Int)

This is a shortcut for ```quantum_number(n)```.
"""
function quantum(n::Int)
	return quantum_number(n)
end

"""
	gaussian_binomial(m::Int, r::Int, q::RingElem)

The **Gaussian binomial coefficient** ``\\begin{bmatrix} m \\\\ r \\end{bmatrix}_q`` , also known as **q-binomial coefficient** is defined by:

```math
\\begin{bmatrix} m \\\\ r \\end{bmatrix}_q = \\begin{cases}{\\frac{(1-q^m)(1-q^{m-1})⋯(1-q^{m-r+1})}{(1-q)(1-q^2)⋯(1-q^r)}} & r≤m \\\\ 0 & r>m \\end{cases} \\;
```
"""
function gaussian_binomial(m::Int, r::Int, q::RingElem)
	m >= 0 || throw(ArgumentError("m ≥ 0 required"))
	r >= 0 || throw(ArgumentError("r ≥ 0 required"))

	R = parent(q)
	if isone(q)
		return R(binomial(m,r))
	elseif  r>m
		return R(0)
	else
		num = one(R) #the numerator
		den = one(R) #the denominator
		for i = 1:min(r,m-r)
			mul!(num, num, one(R)-q^(m-i+1))
			mul!(den, den, one(R)-q^i)
		end
		return divexact(num, den)
	end
end
