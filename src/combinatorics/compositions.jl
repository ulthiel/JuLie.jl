################################################################################
# Compositions.
#
# Copyright (C) 2021 Ulrich Thiel, ulthiel.com/math
################################################################################

export Composition, num_compositions, compositions


"""
    Composition{T} <: AbstractArray{T,1}

A **composition** of an integer n ≥ 0 is a sequence (λ₁,…,λₖ) of positive integers λᵢ whose sum is equal to n. Compositions can also be thought of as **ordered partitions** of n.

Compositions are implemented as a subtype of 1-dimensional integer arrays and you can thus work with compositions like with arrays. You can use smaller integer types to increase performance.

# Examples
```jldoctest
julia> P=Composition([2,1])
[2, 1]
julia> sum(P)
3
julia> P[1]
2
julia> P=Composition(Int8[2,1])
Int8[2, 1]
```

# References
1. Wikipedia, [Composition (combinatorics)](https://en.wikipedia.org/wiki/Composition_(combinatorics))
"""
struct Composition{T} <: AbstractArray{T,1}
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


@doc raw"""
    num_compositions(n::Integer, k::Integer)

The number of compositions of an integer ``n ≥ 0`` into ``k ≥ 0`` parts is equal
```math
\left\lbrace \begin{array}{ll} 1 & \text{if } n=k=0 \\ {n-1 \choose k-1} & \text{otherwise} \;. \end{array} \right.
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
\left\lbrace \begin{array}{ll} 1 & \text{if } n = 0 \\ 2^{n-1} & \text{if } n ≥ 1 \;. \end{array} \right.
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




"""
    compositions(n::Integer, k::Integer)

Returns an array of all compositions of n into k parts. The algorithm used is Algorithm 72 "Composition Generator" by Hellerman & Ogden (1961), which refers to Chapter 6 of Riordan (1958). De-gotoed by E. Thiel. I don't know if there are faster algorithms but this one is already very fast.

# Examples
```jldoctest
julia> compositions(4,2)
3-element Vector{Composition{Int64}}:
 [1, 3]
 [2, 2]
 [3, 1]
```

# References
1. Hellerman, L. & Ogden, S. (1961). Algorithm 72: composition generator. *Communications of the ACM, 4*(11), 498. [https://doi.org/10.1145/366813.366837](https://doi.org/10.1145/366813.366837)
2. Riordan, J. (1958). *An introduction to Combinatorial Analysis*. John Wiley & Sons, Inc., New York.
"""
function compositions(n::Integer, k::Integer)

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


"""
    compositions(n::Integer)

Returns an array of all compositions of an integer n. This iterates over [`compositions(n::Integer, k::Integer)`](@ref) of n into k parts for 1 ≤ k ≤ n.

# Examples
```jldoctest
julia> compositions(3)
4-element Vector{Composition{Int64}}:
 [3]
 [1, 2]
 [2, 1]
 [1, 1, 1]
```
"""
function compositions(n::Integer)

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
        append!(C,compositions(n,k))
    end

    return C

end
