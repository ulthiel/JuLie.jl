################################################################################
# Imprimitive complex reflection groups
#
# Copyright (C) 2021 Ulrich Thiel, ulthiel.com/math
#
################################################################################

export complex_reflection_group

# Abstract type for imprimitive (irreducible) complex reflection groups
abstract type ImprimitiveComplexReflectionGroup <: IrreducibleComplexReflectionGroup end

# Type for standard model of imprimitive complex reflection group
struct ImprimitiveComplexReflectionGroupStd <: ImprimitiveComplexReflectionGroup
	m::Int
	p::Int
	n::Int
	data::Dict{String,Any}
end

function Base.show(io::IO, ::MIME"text/plain", W::ImprimitiveComplexReflectionGroupStd)
	print(io, "Standard model of imprimitive complex reflection group G()")
end

# Type for element of above
struct ImprimitiveComplexReflectionGroupStdElem
	parent::ImprimitiveComplexReflectionGroupStd
	#matrix::MatElem
	label::String
end

function complex_reflection_group(m::Int, p::Int, n::Int)
	W = ImprimitiveComplexReflectionGroupStd(m,p,n,Dict{String,Any}())
	return W
end

#=
"""
	ImprimitiveComplexReflectionGroupType <: IrreducibleComplexReflectionGroupType

In the Shephard–Todd classification [1] of irreducible complex reflection groups, the *imprimitive* ones are of the form G(m,p,n) for positive integers m,p,n satisfying the following conditions:
* p divides m
* n > 1 (otherwise not primitive)
* (m,p,n) ≠ (1,1,n) (otherwise not irreducible)
* (m,p,n) ≠ (2,2,2) (otherwise not irreducible)

The definition of G(m,p,n) is as follows. Let ``C_m`` be the cyclic group of order ``m`` (written multiplicatively) and define
```math
A(m,p,n) := \\{ (\\theta_1,\\ldots,\\theta_n) \\in C_m^n \\mid (\\theta_1 \\cdots \\theta_n)^{m/p} = 1 \\} \\subseteq C_m^n \\;.
```
The symmetric group ``S_n`` acts on ``A(m,p,n)`` by coordinate permutations and we can thus form the semidirect product
```math
G(m,p,n) := A(m,p,n) \\rtimes S_n \\;.
```
The group G(m,p,n) is thus a normal subgroup of
```math
G(m,1,n) = A(m,1,n) \\rtimes S_n \\simeq C_m \\wr S_n
```
of index p.

There are two classes of Weyl groups among them, namely G(2,1,n) is the group ``B_n`` and G(2,2,n) is the group ``D_n``. In addition, the groups G(m,m,2) is the dihedral group of order 2m, i.e. the Coxeter group I₂(m), with G(6,6,2) being the Weyl group G₂.

So far, these groups are not implemented as groups but just as a structure carrying the integers m,p,n. This will be upgraded to an actual group once OSCAR has decided how to do that formally and I know what's the best way to do this. Nonetheless, we can deduce useful information from just the integers.

# Example
```julia-repl
julia> W=ImprimitiveComplexReflectionGroup(2,1,12) #The Weyl group B12
julia> order(W)
1961990553600
```

# References
1. G. Shephard and J. Todd: *Finite unitary reflection groups*, Canad. J. Math. 6 (1954), 274–304.
2. Wikipedia, [Complex reflection groups](https://en.wikipedia.org/wiki/Complex_reflection_group).
"""
struct ImprimitiveComplexReflectionGroupType <: IrreducibleComplexReflectionGroupType
	m::Int
	p::Int
	n::Int

	function ImprimitiveComplexReflectionGroupType(m,p,n)
		# Argument checking to ensure group is irreducible and imprimitive
		m>0 || throw(ArgumentError("m>0 required"))
		p>0 || throw(ArgumentError("p>0 required"))
		n>1 || throw(ArgumentError("n>0 required"))
		m % p == 0 || throw(ArgumentError("m must divide p"))
		(m,p,n) != (1,1,n) || throw(ArgumentError("(m,p,n) ≠ (1,1,n) required"))
		(m,p,n) != (2,2,2) || throw(ArgumentError("(m,p,n) ≠ (2,2,2) required"))
	end
end

"""
	order(W::ImprimitiveComplexReflectionGroup)

The order of the group W. For W=G(m,p,n) this is equal to (mⁿn!)/p, see [1, p274].

# References
1. G. Lehrer and D. Taylor, *Unitary reflection groups*, Australian Mathematical Society Lecture Series, Vol 20, Cambridge University Press (2009).
"""
function order(W::ImprimitiveComplexReflectionGroup)
	m = W.type[1]
	p = W.type[2]
	n = W.type[3]

	# See the book by Lehrer-Taylor, 274.
	return div(ZZ(m)^n*factorial(ZZ(n)), ZZ(p))
end


"""
	rank(W::ImprimitiveComplexReflectionGroup)

By defniniton, the **rank** of W=G(m,p,n) is the number n. This is also equal the dimension of one (any) irreducible reflection representation of W.
"""
function rank(W::ImprimitiveComplexReflectionGroup)

	return W.type[3]

end


"""
	ngens(W::ImprimitiveComplexReflectionGroup)

The cardinality of one (any) minimal generating set of W consisting of reflections of W. For W=G(m,p,n) this number is by [1, p35] equal to:
* n if p=1 or p=m
* n+1 otherwise.

# References
1. G. Lehrer and D. Taylor, *Unitary reflection groups*, Australian Mathematical Society Lecture Series, Vol 20, Cambridge University Press (2009).
"""
function ngens(W::ImprimitiveComplexReflectionGroup)
	m = W.type[1]
	p = W.type[2]
	n = W.type[3]

	if p == 1 || p == m
		return n
	else
		return n+1
	end
end


"""
	is_wellgenerated(W::ImprimitiveComplexReflectionGroup)

The group W is called **well-generated** if it can be generated by n reflections, where n is the rank of W. By [`ngens(W::ImprimitiveComplexReflectionGroup)`](@ref) the group W=G(m,p,n) is well-generated if and only if p=1 or p=m.
"""
function is_wellgenerated(W::ImprimitiveComplexReflectionGroup)
	m = W.type[1]
	p = W.type[2]
	n = W.type[3]

	if p == 1 || p == m
		return true
	else
		return false
	end
end


"""
	degrees(W::ImprimitiveComplexReflectionGroup)

The **degrees** of W are the degrees of one (any) system of fundamental invariants of the invariant ring ℂ[V]ᵂ, where V is one (any) irreducible reflection representation of W and ℂ[V] is the symmetric algebra of the dual of V. We sort the degrees increasingly. For W=G(m,p,n) they are m, 2m, …, (n-1)m, and nm/p, see [1, p274]. We sort them increasingly.

# References
1. G. Lehrer and D. Taylor, *Unitary reflection groups*, Australian Mathematical Society Lecture Series, Vol 20, Cambridge University Press (2009).
"""
function degrees(W::ImprimitiveComplexReflectionGroup)
	m = W.type[1]
	p = W.type[2]
	n = W.type[3]

	d = [ ZZ(i)*ZZ(m) for i=1:n-1 ]
	append!(d,[ZZ(n)*div(ZZ(m),ZZ(p))])
	sort!(d)

	return d
end


"""
	exponents(W::ImprimitiveComplexReflectionGroup)

The **exponents** of W are by definition the integers mᵢ ≔ dᵢ-1, where the dᵢ are the degrees of W.
"""
function exponents(W::ImprimitiveComplexReflectionGroup)
	return [d-1 for d in degrees(W)]
end


"""
	codegrees(W::ImprimitiveComplexReflectionGroup)

The codegrees of W, sorted *decreasingly*. For W=G(m,p,n) they are by [1, p274] given by:
* 0, m, 2m, …, (n-1)m if p ≠ m;
* 0, m, 2m, …, (n-2)m, (n-1)m - n if p=m.

# References
1. G. Lehrer and D. Taylor, *Unitary reflection groups*, Australian Mathematical Society Lecture Series, Vol 20, Cambridge University Press (2009).
"""
function codegrees(W::ImprimitiveComplexReflectionGroup)
	m = W.type[1]
	p = W.type[2]
	n = W.type[3]

	if p != m
		c = [ ZZ(i)*ZZ(m) for i=0:n-1 ]
	else
		c = [ ZZ(i)*ZZ(m) for i=0:n-2 ]
		append!(c, [ZZ(n-1)*ZZ(m)-ZZ(n)])
	end

	sort!(c, rev=true)
	return c
end


"""
	coexponents(W::ImprimitiveComplexReflectionGroup)

The coexponents ``m_i^*`` of W are related to the codegrees ``d_i^*`` via ``m_i^* := d_i^* + 1``.
"""
function coexponents(W::ImprimitiveComplexReflectionGroup)
	return [d+1 for d in codegrees(W)]
end


"""
	num_reflections(W::ImprimitiveComplexReflectionGroup)

The number of (complex) reflections in W. For W=G(m,p,n) this is equal to ``\\frac{1}{2}m(n^2-n)+n\\left(\\frac{m}{p}-1 \\right)``, see [1, Lemma 15.25]. This is also (in general) equal to the sum over the exponents.

# References
1. U. Thiel, *On restricted rational Cherednik algebras* (2014).
"""
function num_reflections(W::ImprimitiveComplexReflectionGroup)
	m = ZZ(W.type[1])
	p = ZZ(W.type[2])
	n = ZZ(W.type[3])

	#The following formula is true for any complex reflection group
	#return sum([m for m in exponents(W)])
	return div(m*(n^2-n),2) + n*(div(m,p)-1)
end


"""
	num_classes_reflections(W::ImprimitiveComplexReflectionGroup)

The number of conjugacy classes of (complex) reflections in W. For W=G(m,p,n) this is by [1, Theorem 15.27] equal to:
* m/p if n>2, or n=2 and p is odd;
* m/p + 1 if n=2 and p is even.

# References
1. U. Thiel, *On restricted rational Cherednik algebras* (2014).
"""
function num_classes_reflections(W::ImprimitiveComplexReflectionGroup)
	m = W.type[1]
	p = W.type[2]
	n = W.type[3]

	# See my thesis
	if n > 2 || (n==2 && isodd(p))
		return ZZ(div(m,p))
	else
		return ZZ(div(m,p) + 1)
	end
end


"""
	num_hyperplanes(W::ImprimitiveComplexReflectionGroup)

The number of reflecting hyperplanes (fixed spaces of complex reflections) of W. This is equal to the sum over the coexponents.

**Remar.** What is actually a reference for this? There should be a closed formula as well.
"""
function num_hyperplanes(W::ImprimitiveComplexReflectionGroup)

	return sum(coexponents(W))

end
=#
