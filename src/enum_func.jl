################################################################################
# Basic enumerative functions.
# Mostly wrappers to FLINT/GMP.
################################################################################

import Nemo: ZZ, QQ, fmpz, fmpq, div, libflint

export fac, rfac, bin, fib, lucas, catalan, bell, stirling1, stirling2, euler, num_partitions, harmonic, bernoulli

"""
The factorial n!.
"""
function fac(n::Integer; alg="gmp")
  if alg=="gmp"
    z = BigInt()
    ccall((:__gmpz_fac_ui, :libgmp), Cvoid, (Ref{BigInt}, Culong), z, n)
    return ZZ(z)
  elseif alg=="flint"
    z = ZZ()
    ccall((:fmpz_fac_ui, libflint), Cvoid, (Ref{fmpz}, Culong), z, n)
    return z
  end
end


"""
The rising factorial n*(n+1)*...*(n+k-1).
"""
function rfac(n::Integer, k::Integer)
  z = ZZ()
  ccall((:fmpz_rfac_uiui, libflint), Cvoid, (Ref{fmpz}, Culong, Culong), z, n, k)
  return z
end


"""
The binomial coefficient n choose k.
"""
# This function is faster than Base.binomial
# (even though it's also using gmp, which doesn't make much sense).
# Also, gmp is quicker than flint.
function bin(n::Integer, k::Integer; alg="gmp")
  if alg=="gmp"
    z = BigInt()
    ccall((:__gmpz_bin_uiui, :libgmp), Cvoid, (Ref{BigInt}, Culong, Culong), z, n, k)
    return ZZ(z)
  elseif alg=="flint"
    z = ZZ()
    ccall((:fmpz_bin_uiui, libflint), Cvoid, (Ref{fmpz}, Culong, Culong), z, n, k)
    return z
  end
end


"""
The n-th Fibonacci number F_n.
"""
# gmp is quicker than flint
function fib(n::Integer; alg="flint")
  if alg=="gmp"
    z = BigInt()
    ccall((:__gmpz_fib_ui, :libgmp), Cvoid, (Ref{BigInt}, Culong), z, n)
    return ZZ(z)
  elseif alg=="flint"
    z = ZZ()
    ccall((:fmpz_fib_ui, libflint), Cvoid, (Ref{fmpz}, Culong), z, n)
    return z
  end
end


"""
The n-th Lucas number L_n.
"""
function lucas(n::Integer; alg="gmp")
  if alg=="gmp"
    z = BigInt()
    ccall((:__gmpz_lucnum_ui, :libgmp), Cvoid, (Ref{BigInt}, Culong), z, n)
    return ZZ(z)
  end
end


"""
The n-th Catalan number C_n.
"""
function catalan(n::Integer; alg="binomial")
  if n==0
    return ZZ(1)
  elseif n==1
    return ZZ(0)
  else
    if alg=="binomial"
      return div( bin(2*n, n), (n + 1) )
    elseif alg=="iterative"
      C = ZZ(1)
      for i=0:n-1
        j = ZZ(i)
        C = div( (4*j+2)*C , j+2)
      end
      return C
    end
  end
end


"""
The n-th Bell number B_n.
"""
function bell(n::Integer)
  z = ZZ()
  ccall((:arith_bell_number, libflint), Cvoid, (Ref{fmpz}, Culong), z, n)
  return z
end


"""
The Stirling number S_1(n,k) of the first kind.
"""
function stirling1(n::Integer, k::Integer)
  z = ZZ()
  ccall((:arith_stirling_number_1, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, n, k)
  return z
end


"""
The Stirling number S_2(n,k) of the second kind.
"""
function stirling2(n::Integer, k::Integer)
  z = ZZ()
  ccall((:arith_stirling_number_2, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, n, k)
  return z
end


"""
The n-th Euler number.
"""
function euler(n::Integer)
  z = ZZ()
  ccall((:arith_euler_number, libflint), Cvoid, (Ref{fmpz}, Culong), z, n)
  return z
end


"""
The n-th Harmonic number.
"""
function harmonic(n::Integer)
  z = QQ()
  ccall((:arith_harmonic_number, libflint), Cvoid, (Ref{fmpq}, Clong), z, n)
  return z
end


"""
The n-th Bernoulli number.
"""
function bernoulli(n::Integer)
  z = QQ()
  ccall((:arith_bernoulli_number, libflint), Cvoid, (Ref{fmpq}, Clong), z, n)
  return z
end


"""
    num_partitions(n::Integer)

The number of integer partitions of the number n. Uses the function arith_number_of_partitions from FLINT [^1].

[^1]: http://flintlib.org/sphinx/arith.html
"""
function num_partitions(n::Integer)
  z = ZZ()
  ccall((:arith_number_of_partitions, libflint), Cvoid, (Ref{fmpz}, Culong), z, n)
  return z
end
