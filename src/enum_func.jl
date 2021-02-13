################################################################################
# Enumerative functions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

import Nemo: libflint

export num_partitions, catalan, stirling1, stirling2, lucas


"""
	catalan(n::fmpz; alg="binomial")
	catalan(n::Integer; alg="binomial")

The n-th Catalan number. This counts a gazillion of things, see [OEIS](https://oeis.org/A000108) for more information. There are two algorithms implemented:

1. "binomial" (*default*): uses a simple formula with binomial coefficients.
2. "iterative": uses an iterative computation.

The binomial computation is much faster:
```
julia> @time x=catalan( ZZ(10)^5 , alg="binomial");
 0.007727 seconds (9 allocations: 95.750 KiB)

julia> @time x=catalan( ZZ(10)^5 , alg="iterative");
 1.572488 seconds (1.01 M allocations: 2.333 GiB, 1.36% gc time)
```
"""
function catalan(n::fmpz; alg="binomial")

	n >= 0 || throw(ArgumentError("n >= 0 required"))

	if n<=1
	return ZZ(1)
	else

	if alg=="binomial"
		return div( binomial(2*n, n), (n + 1) )

	elseif alg=="iterative"
		C = ZZ(1)
		for i=0:Int(n)-1
		j = ZZ(i)
		C = div( (4*j+2)*C , j+2)
		end
		return C
	end

	end
end

function catalan(n::Integer; alg="binomial")
	z = catalan(ZZ(n),alg=alg)
	return Int(z)
end



"""
	stirling1(n::fmpz, k::fmpz)
	stirling1(n::Integer, k::Integer)

The Stirling number ``S_1(n,k)`` of the first kind. The absolute value of ``S_1(n,k)`` counts the number of permutations of ``n`` elements with ``k`` disjoint cycles. The implementation is a wrapper to the function in FLINT.

For more information on these numbers, see [OEIS](https://oeis.org/A008275).
"""
function stirling1(n::fmpz, k::fmpz)

	n >= 0 || throw(ArgumentError("n >= 0 required"))
	k >= 0 || throw(ArgumentError("k >= 0 required"))

	z = ZZ()
	ccall((:arith_stirling_number_1, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, Int(n), Int(k))
	return z
end

function stirling1(n::Integer, k::Integer)
	return Int(stirling1(ZZ(n), ZZ(k)))
end



"""
	stirling2(n::fmpz, k::fmpz)
	stirling2(n::Integer, k::Integer)

The Stirling number ``S_2(n,k)`` of the second kind. This counts the number of partitions of an ``n``-set into ``k`` non-empty subsets. The implementation is a wrapper to the function in FLINT.

For more information on these numbers, see [OEIS](https://oeis.org/A008277).
"""
function stirling2(n::fmpz, k::fmpz)

	n >= 0 || throw(ArgumentError("n >= 0 required"))
	k >= 0 || throw(ArgumentError("k >= 0 required"))

	z = ZZ()
	ccall((:arith_stirling_number_2, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, Int(n), Int(k))
	return z
end

function stirling2(n::Integer, k::Integer)
	return Int(stirling2(ZZ(n), ZZ(k)))
end



"""
	lucas(n::fmpz)
	lucas(n::Integer)

The n-th Lucas number. For more information on these numbers, see [OEIS](https://oeis.org/A000032). The implementation is a wrapper to the function in GMP.
"""
function lucas(n::fmpz)
	n >= 0 || throw(ArgumentError("n >= 0 required"))

	z = BigInt()
	ccall((:__gmpz_lucnum_ui, :libgmp), Cvoid, (Ref{BigInt}, Culong), z, UInt(n))
	return ZZ(z)
end

function lucas(n::Integer)
	return Int(lucas(ZZ(n)))
end


#
# """
#	 euler(n::fmpz)
#	 euler(n::Integer)
#
# The n-th Euler number. Uses FLINT.
# """
# function euler(n::fmpz)
#	 z = ZZ()
#	 ccall((:arith_euler_number, libflint), Cvoid, (Ref{fmpz}, Culong), z, UInt(n))
#	 return z
# end
#
# function euler(n::Integer)
#	 return Int(euler(ZZ(n)))
# end
