################################################################################
# Compositions.
#
# Copyright (C) 2021 Ulrich Thiel, ulthiel.com/math
################################################################################

export Composition, num_compositions, compositions


"""
	Composition{T} <: AbstractArray{T,1}

A **composition** of an integer n is a sequence λ₁,…,λᵣ of positive integers whose sum is equal to n. We have implemented an own type ```Composition``` as subtype of ```AbstractArray{T,1}```.

# Example
```julia-repl
julia> c=Composition([2,1])
julia> sum(c)
3
```
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


"""
	num_compositions(n::Integer)

The number of compositons of an integer n is equal to ``2^{n-1}``.
"""
function num_compositions(n::Integer)
	if n==0
		return ZZ(0)
	else
		return ZZ(2)^(n-1)
	end
end


"""
	compositions(n::Integer, k::Integer)

Returns an array of all compositions of n into k parts. The algorithm used in Algorithm 72 "Composition Generator" by L. Hellerman and S. Ogden, Communications of the ACM, 1961. There may be faster algorithms—I don't know—but we're at least way faster than Sage. De-gotoed by Elisa (as usual).
"""
function compositions(n::Integer, k::Integer)

	# Argument checking
	n >= 0 || throw(ArgumentError("n ≥ 0 required"))
	k >= 0 || throw(ArgumentError("k ≥ 0 required"))

	# Use type of n
	T = typeof(n)

	# This will be the array of compositions
	C = Composition{T}[]

	if k == 0 || k > n
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

Returns an array of all compositions of an integer n.
"""
function compositions(n::Integer)

	# Argument checking
	n >= 0 || throw(ArgumentError("n ≥ 0 required"))

	# Use type of n
	T = typeof(n)

	# This will be the array of compositions
	C = Composition{T}[]

	for k=1:n
		append!(C,compositions(n,k))
	end

	return C

end
