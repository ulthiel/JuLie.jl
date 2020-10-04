################################################################################
# Enumerative functions.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

import Nemo: ZZ, QQ, fmpz, fmpq, div, libflint, UInt

export num_partitions, catalan, stirling1, stirling2, lucas



"""
    num_partitions(n::fmpz)
    num_partitions(n::Integer)

The number of integer partitions of the integer n >= 0. Uses the function from FLINT, which is really fast.

For more information on these numbers, see https://oeis.org/A000041.
"""
function num_partitions(n::fmpz)
  n >= 0 || throw(ArgumentError("n >= 0 required"))
  z = ZZ()
  ccall((:arith_number_of_partitions, libflint), Cvoid, (Ref{fmpz}, Culong), z, UInt(n))
  return z
end

function num_partitions(n::Integer)
  return Int(num_partitions(ZZ(n)))
end



"""
    num_partitions(n::fmpz, k::fmpz)
    num_partitions(n::Integer, k::Integer)

The number of integer partitions of the integer n >= 0 into k >= 0 parts. The implementation uses a recurrence relation.

For more information on these numbers, see https://oeis.org/A008284.
"""
function num_partitions(n::fmpz, k::fmpz)
  n >= 0 || throw(ArgumentError("n >= 0 required"))
  k >= 0 || throw(ArgumentError("k >= 0 required"))

  # Special cases
  if n == k
    return ZZ(1)
  elseif n < k || k == 0
    return ZZ(0)
  elseif k == 1
    return ZZ(1)

  # See https://oeis.org/A008284
  elseif n < 2*k
    if n-k < 0
      return ZZ(0)
    else
      return num_partitions(n-k)
    end

  # See https://oeis.org/A008284
  elseif n <= 2+3*k
    if n-k < 0
      p = ZZ(0)
    else
      p = num_partitions(n-k)
    end
    for i=0:Int(n)-2*Int(k)-1
      p = p - num_partitions(ZZ(i))
    end
    return p

  # Otherwise, use recurrence
  # The following is taken from the GAP code in lib/combinat.gi
  # It uses the standard recurrence relation but in a more intelligent
  # way without recursion.
  else
    n = Int(n)
    k = Int(k)
    p = fill( ZZ(1), n )
    for l = 2:k
      for m = l+1:n-l+1
        p[m] = p[m] + p[m-l]
      end
    end
    return p[n-k+1]
  end

end

function num_partitions(n::Integer, k::Integer)
  return Int(num_partitions(ZZ(n), ZZ(k)))
end



"""
    catalan(n::fmpz; alg="binomial")
    catalan(n::Integer; alg="binomial")

The n-th Catalan number. This counts a gazillion of things, see https://oeis.org/A000108 for more information. There are algorithms implemented:

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

  if n==0
    return ZZ(1)
  elseif n==1
    return ZZ(0)
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

The Stirling number ``S_1(n,k)`` of the first kind. The absolute value of ``S_1(n,k)`` counts the number of permutations of n elements with k disjoint cycles. The implementation is a wrapper to the function in FLINT.

For more information on these numbers, see https://oeis.org/A008275.
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

The Stirling number ``S_2(n,k)`` of the second kind. This counts the number of partitions of an n-set into k non-empty subsets. The implementation is a wrapper to the function in FLINT.

For more information on these numbers, see https://oeis.org/A008277.
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

The n-th Lucas number. For more information on these numbers, see https://oeis.org/A000032. The implementation is a wrapper to the function in GMP.
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
#     euler(n::fmpz)
#     euler(n::Integer)
#
# The n-th Euler number. Uses FLINT.
# """
# function euler(n::fmpz)
#   z = ZZ()
#   ccall((:arith_euler_number, libflint), Cvoid, (Ref{fmpz}, Culong), z, UInt(n))
#   return z
# end
#
# function euler(n::Integer)
#   return Int(euler(ZZ(n)))
# end
