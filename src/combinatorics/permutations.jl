################################################################################
# Permutations.
#
# Copyright (C) 2022 Ulrich Thiel, ulthiel.com/math
################################################################################

export Permutation

# I prefer "Permutations" instead of Perm. We create an alias.
@doc raw"""
	Permutation{T<:Integer}

A **permutation** of a set X is a bijection X → X.

"""
Permutation = Perm
