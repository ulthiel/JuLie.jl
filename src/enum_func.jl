################################################################################
# Basic enumerative functions.
################################################################################

import Nemo: ZZ, QQ, fmpz, fmpq, div, libflint, UInt, bell, bernoulli, binomial, factorial, fibonacci, harmonic, rising_factorial

export bell, bernoulli, binomial, factorial, fibonacci, harmonic, num_partitions, rising_factorial, stirling1, stirling2, euler, catalan, lucas


"""
    lucas(n::fmpz)
    lucas(n::Integer)

The n-th Lucas number L_n. Uses GMP.
"""
function lucas(n::Integer)
  z = BigInt()
  ccall((:__gmpz_lucnum_ui, :libgmp), Cvoid, (Ref{BigInt}, Culong), z, UInt(n))
  return ZZ(z)
end

function lucas(n::Integer)
  return Int(lucas(ZZ(n)))
end


"""
    catalan(n::fmpz; alg="binomial")
    catalan(n::Integer; alg="binomial")

The n-th Catalan number. There are two algorithms:
1. "binomial" (**default**): uses binomial coefficients. This is the fastest.
2. "iterative": uses an iterative computation.
"""
function catalan(n::fmpz; alg="binomial")
  # julia> @time x=catalan( ZZ(10)^5 , alg="iterative");
  #   1.572488 seconds (1.01 M allocations: 2.333 GiB, 1.36% gc time)
  #
  # julia> @time x=catalan( ZZ(10)^5 , alg="binomial");
  #   0.007727 seconds (9 allocations: 95.750 KiB)

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

The Stirling number S_1(n,k) of the first kind. Uses FLINT.
"""
function stirling1(n::fmpz, k::fmpz)
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

The Stirling number S_2(n,k) of the second kind. Uses FLINT.
"""
function stirling2(n::fmpz, k::fmpz)
  z = ZZ()
  ccall((:arith_stirling_number_2, libflint), Cvoid, (Ref{fmpz}, Clong, Clong), z, Int(n), Int(k))
  return z
end

function stirling2(n::Integer, k::Integer)
  return Int(stirling2(ZZ(n), ZZ(k)))
end


"""
    euler(n::fmpz)
    euler(n::Integer)

The n-th Euler number. Uses FLINT.
"""
function euler(n::fmpz)
  z = ZZ()
  ccall((:arith_euler_number, libflint), Cvoid, (Ref{fmpz}, Culong), z, UInt(n))
  return z
end

function euler(n::Integer)
  return Int(euler(ZZ(n)))
end


"""
    num_partitions(n::fmpz)
    num_partitions(n::Integer)

The number of integer partitions of the number n. Uses FLINT.
"""
function num_partitions(n::fmpz)
  z = ZZ()
  # You can't beat this speed!
  ccall((:arith_number_of_partitions, libflint), Cvoid, (Ref{fmpz}, Culong), z, UInt(n))
  return z
end

function num_partitions(n::Integer)
  return Int(num_partitions(ZZ(n)))
end


"""
    num_partitions(n::fmpz, k::fmpz)
    num_partitions(n::Integer, k::Integer)

The number of integer partitions of the number n into k parts. Uses the recurrence relation.
"""
function num_partitions(n::fmpz, k::fmpz)
  n > 0 || throw(ArgumentError("n > 0 required"))
  k >= 0 || throw(ArgumentError("k >= 0 required"))

  #The following is taken from the GAP code in lib/combinat.gi
  #It uses the standard recurrence relation but in a more intelligent
  #way without recursion.
  if n == k
    return ZZ(1)
  elseif n < k || k == 0
    return ZZ(0)
  elseif k == 1
    return ZZ(1)

  # Nice trick I found in Sage src/sage/combinat/partition.py
  # The GAP code would have run for ages
  elseif n <= 2*k
    if n-k <= 0
      return ZZ(0)
    else
      # We have one column of length `k` and all (inner) partitions of
      # size `n-k` can't have length more than `k`
      return num_partitions(n-k)
    end

  else
    p = fill( ZZ(1), Int(n) )
    for l = 2:Int(k)
      for m = l+1:Int(n)-l+1
        p[m] = p[m] + p[m-l]
      end
    end

  end

  return p[Int(n)-Int(k)+1]

end

function num_partitions(n::Integer, k::Integer)
  return Int(num_partitions(ZZ(n), ZZ(k)))
end
