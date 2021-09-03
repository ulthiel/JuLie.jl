################################################################################
# Cartan Matrices.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
#
# Contributed by Tom Schmit.
#
################################################################################

export is_cartan_matrix, CartanMatrix, is_square, adjacency_graph, permute, block_decomposition, is_indecomposable

@doc raw"""
	struct CartanMatrix <: MatElem{fmpz}

A (generalized) **Cartan matrix** is a square matrix ``C`` over the integers satisfying the following conditions:

```math
\begin{aligned}
& C_{i,i} = 2 & \\

& C_{i,j} ≤ 0 \quad \text{ for } \quad i≠j \\

& C_{i,j} = 0 \quad \Leftrightarrow \quad C_{j,i} = 0 \;.
\end{aligned}
```
This definition is as in Carter (2005). Note that in Kac (1990) more generally matrices over the *complex* numbers are considered—but most of the literature just focuses on the integral case.

You can create a CartanMatrix with
```
CartanMatrix( "A4~" )	 #calls essentially CartanMatrix('A', 4, true)
CartanMatrix( "C6" )		#calls essentially CartanMatrix('C', 6)
```
which generates the CartanMatrix: ``\\tilde{A_4}`` resp. ``C_6``

If you would like to generate block diagonal matrices you can do so with
```
CartanMatrix(["A3~","G2","B12"])	#calls essentially CartanMatrix(['A','G','B'],[3,2,12],[true,false,false])
```

# References
1. Carter, R. (2005). *Lie Algebras of Finite and Affine Type*. Cambridge University Press, Cambridge.
1. Kac, V. G. (1990). *Infinite dimensional Lie algebras* (Third edition). Cambridge University Press, Cambridge. (First edition published 1982)

"""
struct CartanMatrix <: MatElem{fmpz}
	 cm::MatElem{fmpz}
	 function CartanMatrix(m::MatElem{fmpz})
		is_cartan_matrix(m) || throw(DomainError(m, "`m` must be a (generalized) Cartan matrix"))
		new(m)
	 end
end


function Base.show(io::IO, mime::MIME"text/plain", CM::CartanMatrix)
	show(io, mime, CM.cm)
end

function Base.size(CM::CartanMatrix)
	return size(CM.cm)
end

base_ring(CM::CartanMatrix) = base_ring(CM.cm)
nrows(CM::CartanMatrix) = nrows(CM.cm)
ncols(CM::CartanMatrix) = ncols(CM.cm)

function Base.size(CM::CartanMatrix, d::Int)
	return size(CM.cm, d)
end

function Base.length(CM::CartanMatrix)
	return length(CM.cm)
end

function Base.getindex(CM::CartanMatrix, i::Int)
	return getindex(CM.cm,i)
end

function Base.getindex(CM::CartanMatrix, i::Int, j::Int)
	return getindex(CM.cm, i, j)
end

function Base.setindex!(CM::CartanMatrix, x::fmpz, i::Int, j::Int)
	return setindex!(CM.cm,x,i,j)
end


"""
	is_cartan_matrix(C::CartanMatrix)

Returns true iff ``C`` is a (generalized) Cartan matrix.
"""
function is_cartan_matrix(C::MatElem)
	#is square
	if size(C,1) != size(C,2)
		return false
	end
	#main diagonal = 2
	for i = 1:size(C,1)
		if C[i,i] != 2
			return false
		end
	end
	#C[i,j]=0 ⇒ C[j,i]=0	and	C[i,j]≤0
	for i = 1:size(C,1)
		for j = 1:i-1
			if C[i,j]>0 || C[j,i]>0 || (C[i,j]==0) ⊻ (C[j,i]==0)
				return false
			end
		end
	end
	return true
end

"""
	CartanMatrix(type::String)

generates the CartanMatrix defined by ``type`` which should be of the following form:
"LN~" or "LN" with L ∈ {A,B,C,D,E,F,G} and N ∈ ℕ.

```
CartanMatrix("LN~")
CartanMatrix("LN")
```
returns ``\\tilde{L_N}`` or ``L_N`` respectively.

for example you could call:
```
CartanMatrix("A12~")
```
"""
function CartanMatrix(type::String)
	#check if the input is in the correct format
	if length(type)<2 || !isletter(type[1]) || (!isdigit(type[end]) && type[end]!='~') || type[end]=='~' && length(type)==2
		throw(ArgumentError("type has to be of the Form: \"LetterNumber\" or \"LetterNumber~\" "))
	end
	for i = 2:length(type)-1
		if !isdigit(type[i])
			throw(ArgumentError("type has to be of the Form: \"LetterNumber\" or \"LetterNumber~\" "))
		end
	end

	tilde = type[end]=='~'
	return CartanMatrix(type[1],parse(Int,type[2:end-tilde]),tilde)
end


"""
	CartanMatrix(type::Char, dim::Int, tilde=false::Bool)

generates the CartanMatrix ``\\tilde{type_{dim}}`` if tilde = true and ``type_{dim}`` otherwise

for example you could call:
```
CartanMatrix('A',12,true)
CartanMatrix('C',7)
```
"""
function CartanMatrix(type::Char, dim::Int, tilde::Bool=false)
	return CartanMatrix([(type, dim, tilde)])
end


"""
	CartanMatrix(types::Array{String,1})

generates the **Cartan block matrix** defined by ``types`` whose elements should be of the following form:
"LN~" or "LN" with L ∈ {A,B,C,D,E,F,G} and N ∈ ℕ.

for example you could call:
```
CartanMatrix( [ "A1~" , "B2" , "C3~" ] )
```
"""
function CartanMatrix(types::Array{String,1})
	if isempty(types)
		throw(ArgumentError("types can't be empty"))
	end
	for type in types
		if length(type)<2 || !isletter(type[1]) || (!isdigit(type[end]) && type[end]!='~') || type[end]=='~' && length(type)==2
			throw(ArgumentError("invalid input: \""*type*" \"	types elements have to be of the form: \"LetterNumber\" or \"LetterNumber~\" "))
		end
		for i = 2:length(type)-1
			if !isdigit(type[i])
				throw(ArgumentError("invalid input: \""*type*" \"	types elements have to be of the form: \"LetterNumber\" or \"LetterNumber~\" "))
			end
		end
	end

	tmp = map(types) do typ
		tilde = typ[end]=='~'
		return (typ[1], parse(Int, typ[2:end-tilde]), tilde)
	end
	return CartanMatrix(tmp)
end


"""
	CartanMatrix(types::Vector{Tuple{Char,Int,Bool}})

generates the **Cartan block matrix** ``types[1]_{dims[1]} ✖ ̃\\tilde{types[2]_{dims[2]}} …`` if for example ``tildes[1]=true, tildes[2]=false, …``

for example you could call:
```julia-repl
julia> CartanMatrix( [('A', 1, true), ('B', 2, false), ('C', 3, true)] )
[ 2  -2   0   0   0   0   0   0]
[-2   2   0   0   0   0   0   0]
[ 0   0   2  -1   0   0   0   0]
[ 0   0  -2   2   0   0   0   0]
[ 0   0   0   0   2  -1   0   0]
[ 0   0   0   0  -2   2  -1   0]
[ 0   0   0   0   0  -1   2  -2]
[ 0   0   0   0   0   0  -1   2]
```
which would return the same as
```julia-repl
julia> CartanMatrix( [ "A1~" , "B2" , "C3~" ] )
[ 2  -2   0   0   0   0   0   0]
[-2   2   0   0   0   0   0   0]
[ 0   0   2  -1   0   0   0   0]
[ 0   0  -2   2   0   0   0   0]
[ 0   0   0   0   2  -1   0   0]
[ 0   0   0   0  -2   2  -1   0]
[ 0   0   0   0   0  -1   2  -2]
[ 0   0   0   0   0   0  -1   2]
```
"""
function CartanMatrix(types::Vector{Tuple{Char,Int,Bool}})
	CM = diagonal_matrix(ZZ(2), sum(t -> t[2] + t[3], types))
	c = 0 # the offset
	for (type, dim, tilde) in types

		if type == 'A'
			dim >= 1 || throw(ArgumentError("dim ≥ 1 required for type = A"*(tilde ? "~" : "")))
			if tilde
				dim += 1
			end
			if dim > 1
				CM[2+c,1+c] = -1
				CM[dim-1+c,dim+c] = -1
			end
			for j = 2+c:dim-1+c
				CM[j-1,j] = -1
				CM[j+1,j] = -1
			end
			if tilde
				if dim == 2	# A1~
					CM[1+c,dim+c] = CM[dim+c,1+c] = -2
				else
					CM[1+c,dim+c] = CM[dim+c,1+c] = -1
				end
			end

		elseif type == 'B'
			dim >= 3 || !tilde || throw(ArgumentError("dim ≥ 3 required for type = B~"))
			dim >=2 || throw(ArgumentError("dim ≥ 2 required for type = B"))

			if dim == 2
				CM[2+c,1+c] = -2
				CM[1+c,2+c] = -1
				c += dim
				continue
			end

			if tilde
				dim += 1
			end

			if tilde
				CM[3+c,1+c] = -1
				CM[1+c,3+c] = -1
			else
				CM[2+c,1+c] = -1
				CM[1+c,2+c] = -1
			end

			CM[3+c,2+c] = -1
			for j = 3+c:dim-2+c
				CM[j-1,j] = -1
				CM[j+1,j] = -1
			end
			CM[dim-2+c,dim-1+c] = -1
			CM[dim+c,dim-1+c] = -2
			CM[dim-1+c,dim+c] = -1

		elseif type=='C'
			dim >= 2 || !tilde || throw(ArgumentError("dim ≥ 2 required for type = C~"))
			dim >= 3 || tilde || throw(ArgumentError("dim ≥ 3 required for type = C"))
			if tilde
				dim += 1
			end

			if tilde
				CM[2+c,1+c] = -2
			else
				CM[2+c,1+c] = -1
			end
			for j = 2+c:dim-1+c
				CM[j-1,j] = -1
				CM[j+1,j] = -1
			end
			CM[dim-1+c,dim+c] = -2

		elseif type == 'D'
			dim >= 4 || throw(ArgumentError("dim ≥ 4 required for type = D"*(tilde ? "~" : "")))

			if tilde
				dim += 1
				CM[3+c,1+c] = -1
				CM[1+c,3+c] = -1
			else
				CM[2+c,1+c] = -1
				CM[1+c,2+c] = -1
			end

			CM[3+c,2+c] = -1
			for j = 3+c:dim-2+c
				CM[j-1,j] = -1
				CM[j+1,j] = -1
			end
			CM[dim+c,dim-2+c] = -1
			CM[dim-2+c,dim-1+c] = -1
			CM[dim-2+c,dim+c] = -1

		elseif type == 'E'
			dim>=6 && dim <=8 || throw(ArgumentError("6 ≤ dim ≤ 8 required for type = E"*(tilde ? "~" : "")))

			if tilde
				dim += 1
			end

			if tilde && dim==7 #E~6
				CM[5+c,1+c] = -1
				CM[1+c,5+c] = -1
			elseif tilde && dim==8 #E~7
				CM[dim+c,1+c] = -1
				CM[1+c,dim+c] = -1
			else
				CM[2+c,1+c] = -1
				CM[1+c,2+c] = -1
			end

			CM[3+c,2+c] = -1
			for j = 3+c:dim-3+c
				CM[j-1,j] = -1
				CM[j+1,j] = -1
			end
			CM[dim-1+c,dim-3+c] = -1
			CM[dim-3+c,dim-2+c] = -1
			CM[dim-3+c,dim-1+c] = -1
			CM[dim+c,dim-1+c] = -1
			CM[dim-1+c,dim+c] = -1

		elseif type == 'F'
			dim == 4 || throw(ArgumentError(" dim=4	required for type = F"*(tilde ? "~" : "")))

			CM[2+c,1+c] = -1
			CM[1+c,2+c] = -1
			if !tilde
				CM[3+c,2+c] = -2
				CM[2+c,3+c] = -1
				CM[4+c,3+c] = -1
				CM[3+c,4+c] = -1
			else
				CM[3+c,2+c] = -1
				CM[2+c,3+c] = -1
				CM[4+c,3+c] = -2
				CM[3+c,4+c] = -1
				CM[5+c,4+c] = -1
				CM[4+c,5+c] = -1
			end

		elseif type == 'G'
			dim == 2 || throw(ArgumentError(" dim=2	required for type == G"*(tilde ? "~" : "")))

			CM[2+c,1+c] = -1
			if tilde
				CM[1+c,2+c] = -1
				CM[3+c,2+c] = -3
				CM[2+c,3+c] = -1
			else
				CM[1+c,2+c] = -3
			end

		else
			throw(ArgumentError("type has to be either \'A\', \'B\', \'C\', \'D\', \'E\', \'F\' or \'G\'"))
		end
		c += dim
	end
	return CartanMatrix(CM)
end




@doc raw"""
	is_square(M::MatElem)

Returns true iff ``M`` is a square matrix, i.e. the number of rows is equal to the number of columns. If true, the dimension is returned as well.
"""
function is_square(M::MatElem)
	n = nrows(M)
	m = ncols(M)
	if n == m
		return true, n
	else
		return false, nothing
	end
end

@doc raw"""
	adjacency_graph(M::MatElem)

The **adjacency graph** of an ``(n × n)``-matrix ``M`` is the undirected graph with vertices ``1,…,n`` and an edge from ``i`` to ``j`` if and only if ``i \ne j`` and ``M_{ij} ≠ 0``. The adjacency graph is returned as a ```SimpleGraph``` fom the [LightGraphs](https://github.com/JuliaGraphs/LightGraphs.jl) package.
"""
function adjacency_graph(M::MatElem)
	b, n = is_square(M)
	b || throw(ArgumentError("The matrix has to be a square matrix"))

	G = SimpleGraph(n);
	for i=1:n
		for j=i+1:n
			if M[i,j] != 0
				add_edge!(G, i, j);
			end
		end
	end
	return G
end

@doc raw"""
	permute(M::MatElem, σ::Perm)

Given an ``(n × n)``-matrix ``M`` and a permutation ``σ ∈ S_n``, this function returns the matrix ``M^\sigma`` with ``(M^\sigma)_{ij} ≔ M_{\sigma(i) \sigma(j)}``, i.e. the rows and columns are permuted by ``σ``.
"""
function permute(M::MatElem, σ::Perm)
	b, n = is_square(M)
	b || throw(ArgumentError("The matrix has to be a square matrix"))

	Mσ = zero_matrix(base_ring(M), n, n)
	for i=1:n
		for j=1:n
			Mσ[i,j] = M[σ[i],σ[j]]
		end
	end
	return Mσ
end

@doc raw"""
	block_decomposition(M::MatElem)

Let ``M`` be an ``(n × n)``-matrix. A **block decomposition** of ``M`` is a collection of square matrices ``B_1,\ldots,B_r`` together with a permutation ``σ ∈ S_n`` such that the matrix ``M^\sigma`` obtained by applying the permutation ``\sigma`` to the rows and columns of ``M`` is the block diagonal sum of the ``B_i``. Up to reordering of the ``B_i`` and up to simulatenous row and column permutation of each ``B_i``, a block decomposition is unique and corresponds to the connected components of the adjacency graph of ``M``.
"""
function block_decomposition(M::MatElem)
	b,n = is_square(M)
	b || throw(ArgumentError("The matrix has to be a square matrix"))

	G = adjacency_graph(M)
	cpts = connected_components(G)
	S = SymmetricGroup(n)
	σ = S(collect(Iterators.flatten(cpts)))
	blocks = typeof(M)[]
	R = base_ring(M)
	k = 0
	for c in cpts
		l = length(c)
		B = zero_matrix(R, l, l)
		for i=1:l
			for j=1:l
				B[i,j] = M[σ[i+k],σ[j+k]]
			end
		end
		push!(blocks, B)
		k += l
	end
	return blocks, σ
end

@doc raw"""
	is_indecomposable(C::MatElem)

A square matrix ``M`` is **indecomposable** if it has no non-trivial block decomposition, i.e. the adjacency graph of ``M`` is connected.
"""
function is_indecomposable(C::MatElem)
	G = adjacency_graph(C)
	n = length(connected_components(G))
	return n == 1
end
