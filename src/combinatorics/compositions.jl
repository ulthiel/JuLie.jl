################################################################################
# Compositions of an integer.
#
# Copyright (C) 2021 Ulrich Thiel, ulthiel.com/math
################################################################################

export
    Composition, CompositionsFixedNumParts, Compositions,
    num_compositions, compositions, compositions_old


################################################################################
# Type for compositions
################################################################################
"""
    Composition{T<:Integer} <: AbstractArray{T,1}

A **composition** (also called **ordered partition**) of an integer n ≥ 0 is a sequence (λ₁,…,λₖ) of positive integers λᵢ whose sum is equal to n. The λᵢ are called the **parts** of the composition.

# Examples
```julia-repl
julia> c=Composition([2,1])
[2, 1]
julia> sum(c)
3
julia> c[1]
2
```

# References
1. Wikipedia, [Composition (combinatorics)](https://en.wikipedia.org/wiki/Composition_(combinatorics))
2. Bóna, M. (2017). *A Walk Through Combinatorics* (Fourth Edition). World Scientific.
"""
struct Composition{T<:Integer} <: AbstractArray{T,1}
    p::Array{T,1}
end

# The following are functions to make the Composition struct array-like.
function Base.show(io::IO, ::MIME"text/plain", P::Composition)
    print(io, P.p)
end

function Base.size(P::Composition)
    return size(P.p)
end

function Base.length(P::Composition)
    return length(P.p)
end

function Base.getindex(P::Composition, i::Int)
    return getindex(P.p,i)
end

function Base.setindex!(P::Composition, x::Integer, i::Int)
    return setindex!(P.p,x,i)
end

function Base.copy(P::Composition{T}) where T<:Integer
  return Composition{T}(copy(P.p))
end


################################################################################
# Number of compositions (easy).
################################################################################
@doc raw"""
    num_compositions(n::Integer, k::Integer)

The number of compositions of an integer ``n ≥ 0`` into ``k ≥ 0`` parts is equal to
```math
\left\lbrace \begin{array}{ll}
    1 & \text{if } n=k=0 \\
    {n-1 \choose k-1} & \text{otherwise} \;.
\end{array} \right.
```
See Corollary 5.3 of Bóna (2017).

# References
1. Bóna, M. (2017). *A Walk Through Combinatorics* (Fourth Edition). World Scientific.
"""
function num_compositions(n::Integer, k::Integer)

    # Argument checking
    n >= 0 || throw(ArgumentError("n ≥ 0 required"))
    k >= 0 || throw(ArgumentError("k ≥ 0 required"))

    if n == 0 && k == 0
        return ZZ(1)
    else
        return binomial(ZZ(n-1),ZZ(k-1))
    end
end


@doc raw"""
    num_compositions(n::Integer)

The number of compositions of an integer ``n ≥ 0`` is equal to
```math
\left\lbrace \begin{array}{ll}
    1 & \text{if } n = 0 \\
    2^{n-1} & \text{if } n ≥ 1 \;.
\end{array} \right.
```
See Corollary 5.4 of Bóna (2017).

# References
1. The On-Line Encyclopedia of Integer Sequences, [A011782](https://oeis.org/A011782)
2. Bóna, M. (2017). *A Walk Through Combinatorics* (Fourth Edition). World Scientific.
"""
function num_compositions(n::Integer)

    # Argument checking
    n >= 0 || throw(ArgumentError("n ≥ 0 required"))

    if n==0
        return ZZ(1)
    else
        return ZZ(2)^(n-1)
    end
end


################################################################################
# Iterator over compositions with fixed number of parts.
################################################################################
"""
    struct CompositionsFixedNumParts{T<:Integer}

Returns an iterator over all compositions of n into k parts. The algorithm used is Algorithm 72 "Composition Generator" by Hellerman & Ogden (1961), which refers to Chapter 6 of Riordan (1958). De-gotoed by E. Thiel.

# Examples
```julia-repl
julia> C = CompositionsFixedNumParts(4,2)
Iterator over compositions of 4 into 2 parts
julia> for c in C
       println(c)
       end
[1, 3]
[2, 2]
[3, 1]
```

# References
1. Hellerman, L. & Ogden, S. (1961). Algorithm 72: composition generator. *Communications of the ACM, 4*(11), 498. [https://doi.org/10.1145/366813.366837](https://doi.org/10.1145/366813.366837)
2. Riordan, J. (1958). *An introduction to Combinatorial Analysis*. John Wiley & Sons, Inc., New York.
"""
struct CompositionsFixedNumParts{T<:Integer}
    n::T
    k::T

    function CompositionsFixedNumParts(n::T,k::T) where T <: Integer

        # Argument checking
        n >= 0 || throw(ArgumentError("n ≥ 0 required"))
        k >= 0 || throw(ArgumentError("k ≥ 0 required"))

        # Create type
        return new{T}(n,k)
    end

end

function Base.show(io::IO, ::MIME"text/plain", P::CompositionsFixedNumParts)
    print(io, "Iterator over compositions of ", P.n, " into ", P.k, " parts")
end

function Base.eltype(P::CompositionsFixedNumParts{T}) where T <: Integer
    return Composition{T}
end

function Base.length(P::CompositionsFixedNumParts)
    return Int(num_compositions(P.n,P.k)) #yields an error if too big, OK!
end

# Iterator initialization
@inline function Base.iterate(P::CompositionsFixedNumParts{T}) where T <: Integer

    # Variable names from iterator
    n = P.n
    k = P.k

    # Special cases in which iterator is empty
    if k > n || (n > 0 && k == 0)
        return nothing
    end

    # State vector for the Hellerman-Ogden algorithm
    # First, some special cases that finish immediately
    if n == 0 #then k=0 and there is only one composition: the empty one
        c = Composition{T}([])
        finished = true
    elseif k == 1 #then there is only one composition
        c = Composition{T}([n])
        finished = true
    elseif n == k
        c = Composition{T}([1 for i=1:n])
        finished = true
    else
        c = Composition{T}([ [1 for i=1:k-1] ; n-k+1 ])
        finished = false
    end
    d = Array{T,1}([0 for i=1:k])

    return c, (c,d,finished)

end

# Hellerman-Ogden algorithm (de-gotoed version)
@inline function Base.iterate(P::CompositionsFixedNumParts, state)

    # Variable names from iterator
    n = P.n
    k = P.k

    # Variable names from state
    c = state[1]
    d = state[2]
    finished = state[3]

    # Check if finished
    if finished == true
        return nothing
    end

    # Initialization of d and j
    for jk=1:k
        d[jk] = c[jk] - 1
    end

    # Main loop
    for j=k:-1:2
        if d[j]>0
            d[j]=0
            d[j-1]=d[j-1] + 1
            d[k]=c[j]-2
            for jk=1:k
                c[jk] = d[jk] + 1
            end
            state = (c,d,finished)
            return c, state
        end
    end

    return nothing

end

"""
    compositons(n::Integer, k::Integer)

Returns the full list of compositions of n into k parts using the [`CompositionsFixedNumParts`](@ref) iterator.
"""
function compositions(n::Integer, k::Integer)

    C = CompositionsFixedNumParts(n,k)

    return [ copy(c) for c in C ]

end

################################################################################
# Old code before implementing the iterator. Kept here for testing purposes.
################################################################################
function compositions_old(n::Integer, k::Integer)

    # Argument checking
    n >= 0 || throw(ArgumentError("n ≥ 0 required"))
    k >= 0 || throw(ArgumentError("k ≥ 0 required"))

    # Use type of n
    T = typeof(n)

    # This will be the array of compositions
    C = Composition{T}[]

    # Special cases
    if k > n
        return C
    elseif n == 0
        c = Composition{T}([])
        push!(C,copy(c))
        return C
    elseif k == 0
        return C
    end

    # Initialize c
    c = Composition{T}([ [1 for i=1:k-1] ; n-k+1 ])
    push!(C,copy(c))

    if k==1
        return C
    end

    # Initialize d
    d = Array{T,1}([0 for i=1:k])

    while true

        for jk=1:k
            d[jk] = c[jk] -1
        end

        j = k
        Lfound = false

        while j>0 && Lfound == false

            if d[j]>0 #label test successful, then go to set
                d[j]=0
                d[j-1]=d[j-1] + 1
                d[k]=c[j]-2
                for jk=1:k
                    c[jk] = d[jk] + 1
                end
                push!(C,copy(c))
                Lfound=true #while-loop can be immediately left here

            else

                j=j-1 #decrease while loop counter and ...

                # ... now check whether we have already reached the first index.
                if j == 1 # if so, return
                    return C
                end

            end

        end

    end

end


################################################################################
# Iterator over compositions.
################################################################################
"""
    struct Compositions{T<:Integer}

Returns an iterator over all compositions of an integer n. The iterator simply iterates over compositions of n into k parts for 1 ≤ k ≤ n using [`CompositionsFixedNumParts`](@ref).

# Examples
"""
struct Compositions{T<:Integer}
    n::T

    function Compositions(n::T) where T<:Integer

        # Argument checking
        n >= 0 || throw(ArgumentError("n ≥ 0 required"))

        return new{T}(n)
    end

end

function Base.show(io::IO, ::MIME"text/plain", P::Compositions)
    print(io, "Iterator over compositions of ", P.n)
end

function Base.eltype(P::Compositions{T}) where T <: Integer
    return Composition{T}
end

function Base.length(P::Compositions)
    return Int(num_compositions(P.n)) #yields an error if too big, OK!
end

# Iterator initialization
@inline function Base.iterate(P::Compositions{T}) where T <: Integer

    # Variable names from iterator
    n = P.n

    # Special cases in which iterator is empty
    if n == 0
        return nothing
    end

    Ck = CompositionsFixedNumParts(n,T(1))
    next = iterate(Ck)
    return next[1], (Ck,next[2])

end

# Actual algorithm
@inline function Base.iterate(P::Compositions{T}, state) where T <: Integer

    # Variable names from iterator
    n = P.n

    # Variable names from state
    Ck = state[1]
    Ck_state = state[2]

    # Do next iteration
    next = Base.iterate(Ck, Ck_state)

    # It took me DAYS to figure out that a != below causes additional
    # allocations!
    # I looked at https://github.com/JuliaLang/julia/blob/master/base/iterators.jl
    # and saw they're using === and !==
    # I think the problem is that next is mostly of type Vector and I could
    # have overloaded != for Vector, and this check causes an allocation.
    # No idea if this is correct but the !== reduces the allocations and
    # it works.
    if next !== nothing
        return next[1], (Ck, next[2])
    else
        k = Ck.k
        if k == n
            return nothing
        else
            k += T(1)
            Ck = CompositionsFixedNumParts(n,k)
            next = Base.iterate(Ck)
            return next[1], (Ck, next[2])
        end
    end
end


"""
    compositons(n::Integer)

Returns the full list of compositions of n using the [`Compositions`](@ref) iterator.
"""
function compositions(n::Integer)

    C = Compositions(n)

    return [ copy(c) for c in C ]

end


################################################################################
# Old code before implementing the iterator. Kept here for testing purposes.
################################################################################
function compositions_old(n::Integer)

    # Argument checking
    n >= 0 || throw(ArgumentError("n ≥ 0 required"))

    # Use type of n
    T = typeof(n)

    # This will be the array of compositions
    C = Composition{T}[]

    # Special case
    if n == 0
        c = Composition{T}([])
        push!(C,copy(c))
        return C
    end

    for k=1:n
        append!(C,compositions_old(n,k))
    end

    return C

end
