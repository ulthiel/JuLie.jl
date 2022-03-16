# [Basic algebraic structures: OSCAR](@id OSCAR)

The goal of the [OSCAR](https://oscar.computeralgebra.de) project (which is short for *Open Source Computer Algebra Research*) is to develop a modern, high-performance, mathematically sound computer algebra system based on Julia and integrating existing computer algebra systems. Part of the OSCAR [ecosystem](https://oscar.computeralgebra.de/documentation/) are the following Julia packages:

* [AbstractAlgebra.jl](https://nemocas.github.io/AbstractAlgebra.jl/stable/): generic algebraic structures in pure Julia (like a general type of rings and of polynomial rings over a ring).
* [Nemo.jl](https://nemocas.github.io/Nemo.jl/stable/): very fast arithmetic for special rings (like the integers and polynomial rings over the integers)—often based on the [FLINT](https://www.flintlib.org) library.
* [Hecke.jl](http://www.thofma.com/Hecke.jl/stable/): algebraic number theory.
* [GAP.jl](https://oscar-system.github.io/GAP.jl/dev/): [GAP](https://www.gap-system.org) integration.
* [Singular.jl](https://oscar-system.github.io/Singular.jl/dev/): [Singular](https://www.singular.uni-kl.de) integration.
* [Oscar.jl](https://oscar-system.github.io/Oscar.jl/dev/): high-level package combining and extending the above.

JuLie may be considered as a further contribution to the OSCAR project and in particular integrates with and builds upon this ecosystem. Here is an overview of basic algebraic structures from OSCAR that are used in JuLie (see [here](https://github.com/ulthiel/JuLie.jl/blob/master/src/JuLie.jl) for the full list of imports):

* Big [integers](https://nemocas.github.io/Nemo.jl/stable/integer/) of type ```fmpz``` (with shortcut ```ZZ```) from Nemo, e.g. ```ZZ(5)```. We prefer this to ```BigInt``` because it is what is used in Nemo and is faster.
* Big exact [rationals](https://nemocas.github.io/Nemo.jl/stable/rational/) of type ```fmpq``` (with shortcut ```QQ```) from Nemo, e.g. ```QQ(5//3)``` or ```ZZ(5)//ZZ(3)```.
* [Finite fields](https://nemocas.github.io/Nemo.jl/stable/finitefield/) from Nemo, e.g. ```R, x = FiniteField(7, 3, "x")``` creates the field of characteristic 7 and of degree 3 over the prime field (i.e. having 7³=343 elements) and with primitive element ```x```.
* [Cyclotomic fields](https://nemocas.github.io/Nemo.jl/stable/numberfield/#Nemo.CyclotomicField-Tuple{Int64,%20String}) from Nemo, e.g. ```K,z = CyclotomicField(3, "z")```.
* [Univariant polynomial rings](https://nemocas.github.io/Nemo.jl/dev/polynomial/), e.g. ```R, x = PolynomialRing(ZZ, "x")``` creates the  univariate polynomial ring over the integers with indeterminate ```x```. This is implemented generically in AbstractAlgebra but there are special types for rings optimized in Nemo.
* [Multivariate polynomial rings](https://nemocas.github.io/Nemo.jl/dev/mpolynomial/), e.g. ```R, (x, y) = PolynomialRing(ZZ, ["x", "y"])``` creates the multivariate polynomial ring over the integers with indeterminates ```x``` and ```y```. Again, there are special types for rings optimized in Nemo.
* [Univariate Laurent polynomial rings](https://nemocas.github.io/AbstractAlgebra.jl/stable/laurent_polynomial/), e.g. ```R, x = LaurentPolynomialRing(ZZ, "x")```.
* [Matrices](https://nemocas.github.io/Nemo.jl/stable/matrix/), e.g. ```M = matrix(ZZ, [3 1 2; 2 0 1])```. Again, there are special types for rings optimized in Nemo.
* [Vector spaces](https://nemocas.github.io/AbstractAlgebra.jl/stable/free_module/), e.g. ```VectorSpace(QQ, 2)```, and [free modules](https://nemocas.github.io/AbstractAlgebra.jl/stable/free_module/), e.g. ```FreeModule(ZZ, 3)```.

