# Motivation

The ultimate goal of JuLie is to help finding new results in (and around) [representation theory](https://en.wikipedia.org/wiki/Representation_theory). Since there's a lot already in other computer algebra systems (like [GAP](https://www.gap-system.org), [Magma](http://magma.maths.usyd.edu.au/magma/), and [Sage](https://www.sagemath.org)), it may seem absurd to start a new project and not simply build on the existing systems. But there is a very good reason: the programming language [Julia](https://julialang.org) which was introduced in 2012 (see also the [Wikipedia](https://en.wikipedia.org/wiki/Julia_(programming_language)) article). The advantages of Julia—that may not all exist to such an extend in other systems—are the following:

1. Through its [type system](https://docs.julialang.org/en/v1/manual/types/) and [multiple dispatch](https://docs.julialang.org/en/v1/manual/methods/) it is possible to model mathematical structures roughly in the same way you think about them abstractly (this is what I mean by "mathematically sound").
2. It is very fast and memory efficient (see the [benchmarks](@ref Benchmarks) of JuLie).
3. It has a straightforward high-level syntax that makes code easy to write and read.
4. It is open source and community-driven.
5. It is modern.

These points speak in favor of using Julia as basis for modern computer algebra. This is exactly the motivation and the goal of the [OSCAR](https://oscar.computeralgebra.de) project started in 2017 (see also my [overview](@ref OSCAR)). JuLie may be considered as a contribution to OSCAR in the field of representation theory (which in turn is another motivation for JuLie). The basic philosophy of this whole enterprise is to:

1. Implement mathematically sound structures.
2. Be fast.

One "milestone" of JuLie is to implement "all" the material from (and as in) the book [Introduction to Soergel bimodules](https://www.springer.com/gp/book/9783030488253) by B. Elias, S. Makisumi, U. Thiel, and G. Williamson. Of course, anything else is always welcome: please [contribute](@ref Contributing)!

