################################################################################
# JuLie.jl
#
# A combinatorics package for Julia.
#
# Copyright (C) 2020-2021 Ulrich Thiel, ulthiel.com/math
################################################################################

module JuLie

################################################################################
# Import
################################################################################

# AbstractAlgebra
import AbstractAlgebra:

	# General stuff
	base_ring, gen, gens, parent_type,

	# Groups
	Group, SymmetricGroup, Perm,

	# Group element operations
	order,

	# Ring element operations
	RingElem,
	addeq!, mul!, divexact,

	# Polynomial rings
	MPolyBuildCtx, PolynomialRing, nvars,

	# Laurent polynomial ring
	LaurentPolynomialRing,

	# Constructing polynomials
	finish, push_term!,

	# Matrices
	MatElem, MatrixAlgebra,
	diagonal_matrix, identity_matrix, matrix, ncols, nrows, zero_matrix,

	# Vector spaces
	VectorSpace, FreeModule

# Nemo
import Nemo:

	# Basic rings
	fmpz, ZZ, fmpq, QQ, FiniteField, CyclotomicField, nf_elem,

	# Univariate polynomials
	fmpz_poly, FmpzPolyRing, fmpq_poly, FmpqPolyRing,

	# Multivariate polynomials
	fmpz_mpoly, FmpzMPolyRing, fmpq_mpoly, FmpqMPolyRing,

	# Matrices
	fmpz_mat, FmpzMatSpace, fmpq_mat, FmpqMatSpace,

	# Libs
	libflint,

	# Combinatorial functions
	bell, bernoulli, binomial, factorial, fibonacci, harmonic, rising_factorial

# LightGraphs
import LightGraphs:

	SimpleGraph, add_edge!, connected_components, vertices, edges

################################################################################
# Export (more exports are in the various source files)
################################################################################
export
	# Rings from Nemo
	QQ, ZZ, FiniteField, CyclotomicField,

	# General stuff from AbstractAlgebra
	base_ring, gen, gens, parent_type,

	# Groups from AbstractAlgebra
	SymmetricGroup, Perm,

	# Rings from AbstractAlgebra
	LaurentPolynomialRing, PolynomialRing,
	nvars,

	# Matrices from AbstractAlgebra
	matrix, identity_matrix, ncols, nrows, zero_matrix,

	# Combinatorial functions from Nemo
	bell, bernoulli, binomial, factorial, fibonacci, harmonic, rising_factorial,

	# Vector spaces from AbstractAlgebra
	VectorSpace, FreeModule,

	# LightGraphs
	SimpleGraph, add_edge!, connected_components, vertices, edges


################################################################################
# JuLie source files
################################################################################
include("enum_func.jl")
include("partitions.jl")
include("compositions.jl")
include("multipartitions.jl")
include("multiset_partitions.jl")
include("quantum_analogs.jl")
include("tableaux.jl")
include("kostka_polynomials.jl")
include("schur_polynomials.jl")
#include("block_matrices.jl")
#include("cartan_matrices.jl")












end # module
