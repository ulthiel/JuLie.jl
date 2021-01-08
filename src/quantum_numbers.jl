################################################################################
# Quantum numbers
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

import AbstractAlgebra: LaurentPolynomialRing, RingElem

export quantum, quantum_number



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

The quantum number ``[n]_q`` where q is the interdeterminate of the Laurent polynomial ring ``\\mathbb{Z}[q,q^{-1}]`` in one variable over the integers.
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
