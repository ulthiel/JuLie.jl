################################################################################
# JuLie.jl
#
#	A combinatorics package for Julia.
#
# Copyright (C) 2020-2021 Ulrich Thiel, ulthiel.com/math
################################################################################

module JuLie

################################################################################
# Import/export for JuLie environment
################################################################################

# AbstractAlgebra
import AbstractAlgebra:

	# General stuff
	base_ring, gens, parent_type,

	# Ring element operations
	RingElem,
	addeq!, mul!, divexact,

	# Polynomials
	LaurentPolynomialRing, MPolyBuildCtx, PolynomialRing,
	finish, push_term!,

	# Matrices
	MatElem, MatrixAlgebra,
	diagonal_matrix, identity_matrix, matrix, ncols, nrows, zero_matrix

# Nemo
import Nemo:

	# Number types
	fmpz, fmpq, ZZ, QQ,

	# Polynomials
	FmpzMPolyRing, fmpz_mpoly,

	# Libs
	libflint,

	# Combinatorial functions
	bell, bernoulli, binomial, factorial, fibonacci, harmonic, rising_factorial

# Export
export
	# Rings from Nemo
	QQ, ZZ,

	# Rings from AbstractAlgebra
	LaurentPolynomialRing, PolynomialRing,

	# Matrices from AbstractAlgebra
	matrix, identity_matrix, ncols, nrows, zero_matrix,

	# Combinatorial functions from Nemo
	bell, bernoulli, binomial, factorial, fmpq, fmpz, fibonacci, harmonic, rising_factorial


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
include("quantum_numbers.jl")

#
# #include("crg.jl")
# include("crg_imprim.jl")
# #include("hecke_parameters.jl")


end # module
