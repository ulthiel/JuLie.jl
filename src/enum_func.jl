################################################################################
# Basic enumerative functions.
#
# Copyright (C) 2020–2021 Ulrich Thiel, ulthiel.com/math
################################################################################

export catalan, stirling1, stirling2, lucas, euler

"""
	catalan(n::fmpz)
	catalan(n::Integer)

The n-th Catalan number ``C_n``. The computation simply uses the formula
```math
C_n = \\frac{1}{n+1}{ 2n \\choose n} \\;.
```

# Refences
1. [OEIS](https://oeis.org/A000108)
2. [Wikipedia](https://en.wikipedia.org/wiki/Catalan_number)
"""
function catalan(n::fmpz)

	n >= 0 || throw(ArgumentError("n ≥ 0 required"))

	if n<=1
		return ZZ(1)
	else
		return div( binomial(2*n, n), (n + 1) )
	end

end

function catalan(n::Integer)
	z = catalan(ZZ(n))
	return z
end



"""
	stirling1(n::fmpz, k::fmpz)
	stirling1(n::Integer, k::Integer)

The Stirling number S₁(n,k) of the first kind. The absolute value of S₁(n,k) counts the number of permutations of n elements with k disjoint cycles. The implementation is a wrapper to the function in [FLINT](http://flintlib.org).

# References
1. [OEIS](https://oeis.org/A008275)
2. [Wikipedia](https://en.wikipedia.org/wiki/Stirling_numbers_of_the_first_kind)
"""
function stirling1(n::fmpz, k::fmpz)

	n >= 0 || throw(ArgumentError("n >= 0 required"))
	k >= 0 || throw(ArgumentError("k >= 0 required"))

	z = ZZ()
	ccall((:arith_stirling_number_1, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, Int(n), Int(k))
	return z
end

function stirling1(n::Integer, k::Integer)
	z = stirling1(ZZ(n), ZZ(k))
	return z
end



"""
	stirling2(n::fmpz, k::fmpz)
	stirling2(n::Integer, k::Integer)

The Stirling number S₂(n,k) of the second kind. This counts the number of partitions of an n-element set into k non-empty subsets. The implementation is a wrapper to the function in [FLINT](http://flintlib.org).

# References
1. [OEIS](https://oeis.org/A008277)
2. [Wikipedia](https://en.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind)
"""
function stirling2(n::fmpz, k::fmpz)

	n >= 0 || throw(ArgumentError("n >= 0 required"))
	k >= 0 || throw(ArgumentError("k >= 0 required"))

	z = ZZ()
	ccall((:arith_stirling_number_2, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, Int(n), Int(k))
	return z
end

function stirling2(n::Integer, k::Integer)
	z = stirling2(ZZ(n), ZZ(k))
	return z
end



"""
	lucas(n::fmpz)
	lucas(n::Integer)

The n-th Lucas number. The implementation is a wrapper to the function in [GMP](https://gmplib.org).

# References
1. [OEIS](https://oeis.org/A000032)
2. [Wikipedia](https://en.wikipedia.org/wiki/Lucas_number)
"""
function lucas(n::fmpz)
	n >= 0 || throw(ArgumentError("n >= 0 required"))

	z = BigInt()
	ccall((:__gmpz_lucnum_ui, :libgmp), Cvoid, (Ref{BigInt}, Culong), z, UInt(n))
	return ZZ(z)
end

function lucas(n::Integer)
	z = lucas(ZZ(n))
	return z
end



"""
	 euler(n::fmpz)
	 euler(n::Integer)

The n-th Euler number. The implementation is a wrapper to [FLINT](http://flintlib.org).

# References
1. [OEIS](https://oeis.org/A122045)
2. [Wikipedia](https://en.wikipedia.org/wiki/Euler_numbers)
"""
function euler(n::fmpz)
	 z = ZZ()
	 ccall((:arith_euler_number, libflint), Cvoid, (Ref{fmpz}, Culong), z, UInt(n))
	 return z
end

function euler(n::Integer)
	 z = euler(ZZ(n))
	 return z
end
