################################################################################
# JuLie.jl
#
#	A combinatorics package for Julia.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
################################################################################

module JuLie

################################################################################
# Import/export for JuLie environment
################################################################################

# Nemo
import Nemo: ZZ, QQ, Int, UInt, fmpz, binomial, factorial, bell, fibonacci, rising_factorial, bernoulli, harmonic, PolynomialRing, parent_type, base_ring, fmpz_poly, mul!, fmpz_mpoly, FmpzMPolyRing

export ZZ, QQ, Int, UInt, fmpz, binomial, factorial, bell, fibonacci, rising_factorial, bernoulli, harmonic, PolynomialRing, base_ring, fmpz_poly, mul!, fmpz_mpoly, FmpzMPolyRing

# AbstractAlgebra
import AbstractAlgebra.Generic: FreeModule, VectorSpace, gen, gens

import AbstractAlgebra: SymmetricGroup, Perm, order, base_ring, nrows, ncols, MatElem, MatrixAlgebra, diagonal_matrix, matrix, zero_matrix, PolynomialRing,  LaurentPolynomialRing, RingElem, divexact

export FreeModule, VectorSpace, gen, gens, SymmetricGroup, Perm, order, base_ring, nrows, ncols, MatElem, MatrixAlgebra, matrix, diagonal_matrix, zero_matrix, PolynomialRing, LaurentPolynomialRing, RingElem, divexact


################################################################################
# Include source files
################################################################################
include("enum_func.jl")

include("compositions.jl")
include("partitions.jl")
include("multipartitions.jl")
include("multiset_partitions.jl")
include("tableaux.jl")
include("kostka_polynomials.jl")
include("schur_polynomials.jl")

include("cartan_matrices.jl")

#include("realizations.jl")



include("quantum_numbers.jl")

#include("crg.jl")
include("crg_imprim.jl")
#include("hecke_parameters.jl")

end # module
