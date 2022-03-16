################################################################################
# Basic enumerative functions.
#
# Copyright (C) 2020–2022 Ulrich Thiel, ulthiel.com/math
################################################################################

export catalan, stirling1, stirling2, lucas, euler

################################################################################
# Functions from Nemo. We update the documentation.
################################################################################
@doc raw"""
	bell(n::T) where T<:Union{Int,fmpz}

The n-th Bell number Bₙ. This counts the number of partitions of an n-element set.

The implementation is the one from [Nemo](https://nemocas.github.io/Nemo.jl/stable/) which in turn uses the one from [FLINT](http://flintlib.org).

# Refences
1. Wikipedia, [Bell number](https://en.wikipedia.org/wiki/Bell_number)
1. The On-Line Encyclopedia of Integer Sequences, [A000110](https://oeis.org/A000110)
"""
bell

@doc raw"""
	binomial(n::T, k::T) where T<:Union{Int,fmpz}

The binomial coefficient ``{n \choose k}``. This counts the number of k-element subsets of an n-element set.

For type ```fmpz``` the implementation is the one from [Nemo](https://nemocas.github.io/Nemo.jl/stable/) which in turn uses the one from [FLINT](http://flintlib.org).

# Refences
1. Wikipedia, [Binomial coefficient](https://en.wikipedia.org/wiki/Binomial_coefficient)
"""
binomial

@doc raw"""
	factorial(n::T) where T<:Union{Int,fmpz}

The factorial of n. This counts the number of permuations of n distinct objects.

For type ```fmpz``` the implementation is the one from [Nemo](https://nemocas.github.io/Nemo.jl/stable/) which in turn uses the one from [FLINT](http://flintlib.org).

# Refences
1. Wikipedia, [Factorial](https://en.wikipedia.org/wiki/Factorial)
1. The On-Line Encyclopedia of Integer Sequences, [A000142](https://oeis.org/A000142)
"""
factorial


################################################################################
# Functions from FLINT.
################################################################################

"""
	stirling1(n::fmpz, k::fmpz)
	stirling1(n::Integer, k::Integer)

The Stirling number S₁(n,k) of the first kind. The absolute value of S₁(n,k) counts the number of permutations of n elements with k disjoint cycles. The implementation is a wrapper to the function in [FLINT](http://flintlib.org).

# References
1. Wikipedia, [Stirling numbers of the first kind](https://en.wikipedia.org/wiki/Stirling_numbers_of_the_first_kind)
1. The On-Line Encyclopedia of Integer Sequences, [A008275](https://oeis.org/A008275)
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
1. Wikipedia, [Stirling numbers of the second kind](https://en.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind)
1. The On-Line Encyclopedia of Integer Sequences, [A008277](https://oeis.org/A008277)
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
2. Wikipedia, [Lucas number](https://en.wikipedia.org/wiki/Lucas_number)
1. The On-Line Encyclopedia of Integer Sequences, [A000032](https://oeis.org/A000032)
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
1. Wikipedia, [Euler numbers](https://en.wikipedia.org/wiki/Euler_numbers)
1. The On-Line Encyclopedia of Integer Sequences, [A122045](https://oeis.org/A122045)
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


################################################################################
# Further functions.
################################################################################
@doc raw"""
	catalan(n::fmpz)
	catalan(n::Integer)

The n-th Catalan number Cₙ. This counts all sorts of things, e.g. the number of expressions containing n pairs of parentheses which are correctly matched.

The computation simply uses the formula
```math
C_n = \frac{1}{n+1}{ 2n \choose n} \;.
```
# Refences
1. Wikipedia, [Catalan number](https://en.wikipedia.org/wiki/Catalan_number)
1. The On-Line Encyclopedia of Integer Sequences, [A000108](https://oeis.org/A000108)
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
