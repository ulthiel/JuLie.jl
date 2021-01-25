using Test
using JuLie
import Nemo: ZZ, QQ
import AbstractAlgebra: LaurentPolynomialRing, PolynomialRing

@testset "Enumerative functions" begin

	# num_partitions
	@test num_partitions(0) == 1
	@test num_partitions(1) == 1

	@test num_partitions(0,0) == 1
	@test num_partitions(1,0) == 0
	@test num_partitions(1,1) == 1
	@test num_partitions(0,1) == 0

	@test num_partitions(ZZ(991)) == ZZ(16839773100833956878604913215477)

	@test num_partitions(ZZ(1991),ZZ(170)) == ZZ(22381599503916828837298114953756766080813312)
	@test num_partitions(ZZ(1991),ZZ(1000)) == ZZ(16839773100833956878604913215477)
	@test num_partitions(ZZ(1991),ZZ(670)) == ZZ(3329965216307826492368402165868892548)
	@test num_partitions(ZZ(1991),ZZ(1991)) == ZZ(1)
	@test num_partitions(ZZ(1991),ZZ(1)) == ZZ(1)

	# catalan
	@test catalan(ZZ(87)) == ZZ(16435314834665426797069144960762886143367590394940)
	@test catalan(ZZ(87), alg="binomial") == ZZ(16435314834665426797069144960762886143367590394940)
	@test catalan(ZZ(87), alg="iterative") == ZZ(16435314834665426797069144960762886143367590394940)

	# stirling
	@test stirling1(ZZ(119),ZZ(97)) == ZZ(231393604360614503792428283097412982860076938212225481588634166)
	@test stirling2(ZZ(117),ZZ(101)) == ZZ(52573293149721609368885842841453741018410117476)

	# lucas
	@test lucas(ZZ(201)) == ZZ(1015116040150328233272520834523487973612876)

end



@testset "Partitions" begin
	# Constructors
	@test Partition(2,2,1) == Partition([2,2,1])
	@test Partition(1) == Partition([1])
	@test Partition() == Partition([])

	@test Partition{Int8}(2,2,1) == Partition(Int8[2,2,1])
	@test typeof(Partition{Int8}(2,2,1)) == typeof(Partition(Int8[2,2,1]))
	@test Partition{Int8}(1) == Partition(Int8[1])
	@test typeof(Partition{Int8}(1)) == typeof(Partition(Int8[1]))
	@test Partition{Int8}() == Partition(Int8[])
	@test typeof(Partition{Int8}()) == typeof(Partition(Int8[]))

	# Unrestricted partitions
	check = true
	N = 0:20
	for n in N
		P = partitions(n)
		# check that number of partitions is correct
		if length(P) != num_partitions(n)
			check = false
			break
		end
		# check that all partitions are distinct
		if P != unique(P)
			check = false
			break
		end
		# check that partitions are really partitions of n
		for lambda in P
			if sum(lambda) != n
				check = false
				break
			end
		end
	end
	@test check==true

	# ascending partitions, similar test as above
	check = true
	N = 0:20
	for n in N
		# go through all algorithms
		for a in [ "ks", "m" ]
			P = ascending_partitions(n,alg=a)
			# check that number of partitions is correct
			if length(P) != num_partitions(n)
				check = false
				break
			end
			# check that all partitions are distinct
			if P != unique(P)
				check = false
				break
			end
			# check that partitions are really partitions of n
			for lambda in P
				if sum(lambda) != n
					check = false
					break
				end
			end
		end
		if check==false
			break
		end
	end
	@test check==true

	# k-restricted partitions
	check = true
	N = 0:20
	for n in N
		for k = 0:n+1
			P = partitions(n,k)
			# check that partitions have k parts
			if length(P) !=0 && unique([ length(p) for p in P ]) != [k]
				check = false
				break
			end
			# check that number of partitions is correct
			if length(P) != num_partitions(n,k)
				check = false
				break
			end
			# check that all partitions are distinct
			if P != unique(P)
				check = false
				break
			end
			# check that partitions are really partitions of n
			for lambda in P
				if sum(lambda) != n
					check = false
					break
				end
			end
		end
		if check==false
			break
		end
	end
	@test check==true

	# k-restricted partitions with lower and upper bounds
	check = true
	N = 0:20
	for n in N
		for k = 0:n+1
			for l1 = 0:n
				for l2 = l1:n
					P = partitions(n,k,l1,l2)
					# check that partitions have k parts
					if length(P) !=0 && unique([ length(p) for p in P ]) != [k]
						check = false
						break
					end
					# check that all partitions are distinct
					if P != unique(P)
						check = false
						break
					end
					# check that partititons are really partitions of n
					for lambda in P
						if sum(lambda) != n
							check = false
							break
						end
					end
					#check that all parts are inside the bounds
					for lambda in P
						for part in lambda
							if part>l2 || part<l1
								check = false
								break
							end
						end
					end
				end
			end
		end
		if check==false
			break
		end
	end
	@test check==true

	# k-restricted partitions with lower and upper bounds and distinct parts
	check = true
	N = 0:20
	for n in N
		for k = 0:n+1
			for l1 = 0:n
				for l2 = l1:n
					P = partitions(n,k,l1,l2,z=1)
					# check that partitions have k parts
					if length(P) !=0 && unique([ length(p) for p in P ]) != [k]
						check = false
						break
					end
					# check that all partitions are distinct
					if P != unique(P)
						check = false
						break
					end
					# check that partititons are really partitions of n
					for lambda in P
						if sum(lambda) != n
							check = false
							break
						end
					end
					#check that all parts are inside the bounds
					for lambda in P
						for part in lambda
							if part>l2 || part<l1
								check = false
								break
							end
						end
					end
					#check that all parts are distinct
					for lambda in P
						if lambda != unique(lambda)
							check = false
							break
						end
					end
				end
			end
		end
		if check==false
			break
		end
	end
	@test check==true

	#= v-mu-restricted partitions aren't yet functional in this package

	# v-mu-restricted partitions
	check = true
	N = 0:20
	for n in N
		for k = 1:n+1
			for i = 1:20
				v=convert(Array{Integer,1},rand(1:20,i))
				unique!(v)
				sort!(v)
				mu=convert(Array{Integer,1},rand((0:k).+1,length(v)))
				println(mu,n,v,k)
				P = partitions(mu,n,v,k)
				# check that partitions have k parts
				if length(P) !=0 && unique([ length(p) for p in P ]) != [k]
					check = false
					break
				end
				# check that all partitions are distinct
				if P != unique(P)
					check = false
					break
				end
				# check that partitions are really partitions of n
				for lambda in P
					if sum(lambda) != n
						check = false
						break
					end
				end
			end
		end
		if check==false
			break
		end
	end
	@test check==true

	=#

	# Dominance order
	@test dominates(Partition([4,2]), Partition([3,2,1])) == true
	@test dominates(Partition([4,1,1]), Partition([3,3])) == false
	@test dominates(Partition([3,3]), Partition([4,1,1])) == false

	# Conjugate partition
	@test conjugate(Partition([6,4,3,1])) == Partition([4, 3, 3, 2, 1, 1])
	@test conjugate(Partition([5,4,1])) == Partition([3, 2, 2, 2, 1])
	check = true
	for p in partitions(10)
		if conjugate(conjugate(p)) != p
			check = false
			break
		end
	end
	@test check==true

	# partcount_to_partition
	@test partcount_to_partition([2,0,1]) == Partition([3,1,1])
	@test partcount_to_partition(Int[]) == Partition([])
	@test partcount_to_partition([3,2,1]) == Partition([3,2,2,1,1,1])

	# partition_to_partcount
	@test partition_to_partcount(Partition([5,3,3,3,2,1,1])) == [2,1,3,0,1]
	@test partition_to_partcount(Partition([])) == []
	@test partition_to_partcount(Partition([3,2,1])) == [1,1,1]

	check = true
	N = 0:20
	for n in N
		for λ in partitions(n)
			if λ != partcount_to_partition(partition_to_partcount(λ))
				check=false
				break
			end
		end
		if check==false
			break
		end
	end
	@test check==true

end

@testset "Multiset-partitions" begin

	#different generating functions
	@test Multiset_partition() == Multiset_partition{Int}()
	@test Multiset_partition() == Multiset_partition(Array{Int,1}[])
	@test Multiset_partition() == Multiset_partition(Partition{Int}[])

	@test Multiset_partition([[3,2,1],[5],[5]]) == Multiset_partition([3,2,1],[5],[5])
	@test Multiset_partition([[3,2,1],[5],[5]]) == Multiset_partition(Partition([3,2,1]),Partition([5]),Partition([5]))
	@test Multiset_partition([[3,2,1],[5],[5]]) == Multiset_partition([Partition([3,2,1]),Partition([5]),Partition([5])])

	@test Multiset_partition(Array{Int8,1}[[3,2,1],[5],[5]]) == Multiset_partition(Int8[3,2,1],Int8[5],Int8[5])
	@test Multiset_partition(Array{Int8,1}[[3,2,1],[5],[5]]) == Multiset_partition(Partition(Int8[3,2,1]),Partition(Int8[5]),Partition(Int8[5]))
	@test Multiset_partition(Array{Int8,1}[[3,2,1],[5],[5]]) == Multiset_partition([Partition(Int8[3,2,1]),Partition(Int8[5]),Partition(Int8[5])])

	# push!
	msp = Multiset_partition()
	push!(msp,Partition([1]),3)
	push!(msp,Partition([3]))
	push!(msp,Partition([3]))
	@test msp == Multiset_partition([3],[3],[1],[1],[1])

	# setindex!
	msp = Multiset_partition()
	setindex!(msp,3,Partition([1]))
	setindex!(msp,2,Partition([2]))
	@test msp == Multiset_partition([2],[2],[1],[1],[1])
	setindex!(msp,2,Partition([1]))
	setindex!(msp,0,Partition([2]))
	@test msp == Multiset_partition([1],[1])

	# union!
	msp = Multiset_partition()
	union!(msp,Partition([1]),Partition([2]),Partition([3]))
	@test msp == Multiset_partition([1],[2],[3])
	union!(msp,Partition([3]),Partition([3]))
	@test msp == Multiset_partition([1],[2],[3],[3],[3])

	# union!
	msp = Multiset_partition([3,2],[5],[2,1],[2,1])
	@test getindex(msp,Partition([3,2])) == 1
	@test getindex(msp,Partition([2,1])) == 2
	@test getindex(msp,Partition([10])) == 0
	@test getindex(Multiset_partition(),Partition([10])) == 0

	# collect
	msp = Multiset_partition([3,2],[5],[2,1],[2,1])
	msp_array = collect(msp)
	@test msp == Multiset_partition(msp_array)
	@test collect(Multiset_partition()) == Partition{Int64}[]

	# isempty
	@test isempty(Multiset_partition()) == true
	@test isempty(Multiset_partition{Int8}()) == true
	@test isempty(Multiset_partition([1])) == false

	# sum
	@test sum(Multiset_partition([2],[2],[8,7,6])) == 25
	@test sum(Multiset_partition([2])) == 2
	@test sum(Multiset_partition()) == 0

	# length
	@test length(Multiset_partition([2],[2],[8,7],[3,2,1])) == 4
	@test length(Multiset_partition([2])) == 1
	@test length(Multiset_partition()) == 0

	# multiset-partitions
	check = true
	N = 0:15
	for n in N
		MSP = multiset_partitions(n)
		# check that all multiset-partitions are distinct
		if MSP != unique(MSP)
			check = false
			break
		end
		# check that multiset-partititons are really multiset-partitions of n
		for msp in MSP
			if sum(msp) != n
				check = false
				break
			end
		end
	end
	@test check==true

	# multiset-partitions of partitions
	check = true
	N = 0:15
	for n in N
		for p in partitions(n)
			MSP = multiset_partitions(p)
			# check that all multiset-partitions are distinct
			if MSP != unique(MSP)
				check = false
				break
			end
			# check that multiset-partititons are really multiset-partitions of n
			for msp in MSP
				if sum(msp) != n
					check = false
					break
				end
			end
			# check that all multiset-partititons are partitions of p
			for msp in MSP
				concat = Int[]
				for P in msp
					append!(concat, P.p)
				end
				sort!(concat, rev=true)
				if Partition(concat) != p
					println(p, concat)
					check = false
					break
				end
			end
		end
	end
	@test check==true

	# k-restricted multiset-partitions
	check = true
	N = 0:15
	K = 1:15
	for n in N
		for k in K
			MSP = multiset_partitions(n,k)
			# check that all multiset-partitions are distinct
			if MSP != unique(MSP)
				check = false
				break
			end
			# check that all multiset-partititons are really multiset-partitions of n
			for msp in MSP
				if sum(msp) != n
					check = false
					break
				end
			end
			# check that all multiset-partitions have k parts
			if !isempty(MSP) && unique([ length(msp) for msp in MSP ]) != [k]
				check = false
				break
			end
		end
	end
	@test check==true
end

@testset "Multi-partitions" begin

	# multi-partitions
	check = true
	N = 0:10
	R = 1:5
	for n in N
		for r in R
			MP = multipartitions(n,r)
			# check that all multipartitions are distinct
			if MP != unique(MP)
				check = false
				break
			end
			# check that multipartititons are really multipartitions of n
			for mp in MP
				lambda=0
				for p in mp
					lambda = lambda + sum(p)
				end
				if lambda != n
					check = false
					break
				end
			end
			# check that all multisetpartitions have k parts
			if length(MP) !=0 && unique([ length(mp) for mp in MP ]) != [r]
				check = false
				break
			end
		end
	end
	@test check==true
end




@testset "Quantum numbers" begin
	R,q = LaurentPolynomialRing(ZZ, "q")
	@test quantum(0) == 0
	@test quantum(1) == 1
	@test quantum(2) == q^-1 + q
	@test quantum(3) == q^-2 + 1 + q^2
	@test quantum(4) == q^-3 + q^-1 + q + q^3
	@test quantum(5) == q^-4 + q^-2 + 1 + q^2 + q^4
	@test quantum(-5) == -quantum(5)
	@test quantum(5, QQ(11)) == QQ(216145205//14641)

	S,t = PolynomialRing(ZZ,"t")
	@test gaussian_binomial(0,0,t) == 1
	@test gaussian_binomial(1,0,t) == 1
	@test gaussian_binomial(1,1,t) == 1
	@test gaussian_binomial(2,1,t) == t + 1
	@test gaussian_binomial(3,1,t) == t^2 + t + 1
	@test gaussian_binomial(3,2,t) == t^2 + t + 1
	@test gaussian_binomial(4,2,t) == t^4 + t^3 + 2*t^2 + t + 1
	@test gaussian_binomial(0,1,t) == 0
	@test gaussian_binomial(2,3,t) == 0

end


@testset "Tableaux" begin
	# reading_word
	@test reading_word(Tableau([ [1,2,5,7], [3,4], [6]])) == [6,3,4,1,2,5,7]
	@test reading_word(Tableau([ [1], [2], [3]])) == [3,2,1]
	@test reading_word(Tableau([[1,2,3]])) == [1,2,3]
	@test reading_word(Tableau([[]])) == Int[]

	# weight
	@test weight(Tableau([[1,2,3],[1,2],[1]])) == [3,2,1]
	@test weight(Tableau([[1,2,3,4,5]])) == [1,1,1,1,1]
	@test weight(Tableau([[1],[1],[1]])) == [3]
	@test weight(Tableau([[]])) == Int[]

	# is_standard
	@test is_standard(Tableau([[1,2,4,7,8],[3,5,6,9],[10]])) == true
	@test is_standard(Tableau([[1,2],[3,4]])) == true
	@test is_standard(Tableau([[1,3],[2,4]])) == true
	@test is_standard(Tableau([[1,4],[2,4]])) == false
	@test is_standard(Tableau([[1,2],[4]])) == false

	# is_semistandard
	@test is_semistandard(Tableau([[1,2,4,7,8],[3,5,6,9],[10]])) == true
	@test is_semistandard(Tableau([[1,2],[3,4]])) == true
	@test is_semistandard(Tableau([[1,3],[2,4]])) == true
	@test is_semistandard(Tableau([[1,4],[2,4]])) == false
	@test is_semistandard(Tableau([[1,2],[4]])) == true
	@test is_semistandard(Tableau([[1,2,2],[3]])) == true
	@test is_semistandard(Tableau([[1,2,3],[1,4]])) == false

	# semistandard_tableaux(shape::Array{T,1}, max_val=sum(shape)::Integer)
	check = true
	shapes = [[3,2,1],[3,3,1],[2,2,2]]
	for s in shapes
		SST = semistandard_tableaux(s)
		#check that all tableaux are distinct
		if SST != unique(SST)
			check = false
			break
		end
		#check that all tableaux are semistandard_tableaux
		for tab in SST
			if !is_semistandard(tab)
				check = false
				break
			end
		end
	end
	@test check==true


	# semistandard_tableaux(s::Array{T,1}, weight::Array{T,1})
	check = true
	shapes = [[5,3,1,1],[4,3,2,1],[2,2,2,2,2]]
	weights = [[1,1,1,1,1,1,1,1,1,1],[3,0,2,0,0,5],[4,3,2,1]]
	for s in shapes
		for w in weights
			SST = semistandard_tableaux(s,w)
			#check that all tableaux are distinct
			if SST != unique(SST)
				check = false
				break
			end
			#check that all tableaux are semistandard_tableaux
			for tab in SST
				if !is_semistandard(tab)
					check = false
					break
				end
			end
			#check that all tableaux have the correct shape
			for tab in SST
				if shape(tab)!=s
					check = false
					break
				end
			end
			#check that all tableaux have the correct weight
			for tab in SST
				if weight(tab)!=w
					check = false
					break
				end
			end
		end
	end
	@test check==true

	# num_standard_tableaux
	# standard_tableaux(s::Partition)
	check = true
	for i = 1:10
		for s in partitions(i)
			ST = standard_tableaux(s)
			#check that all tableaux are distinct
			if ST != unique(ST)
				check = false
				break
			end
			#check that all tableaux are standard_tableaux
			for tab in ST
				if !is_standard(tab)
					check = false
					break
				end
			end
			#check that all tableaux where found
			if length(ST)!=num_standard_tableaux(s)
				check = false
				break
			end
		end
	end
	@test check==true


	# hook_length
	@test hook_length(Partition([1]),1,1) == 1
	@test hook_length(Partition([4,3,1,1]),1,1) == 7

	# hook_lengths
	@test hook_lengths(Partition([4,3,1,1])) == Tableau([[7,4,3,1],[5,2,1],[2],[1]])
	@test hook_lengths(Partition([1])) == Tableau([[1]])
	@test hook_lengths(Partition([])) == Tableau([Int[]])

	# schensted
	@test schensted([6,2,7,3,5,4,1]) == (Tableau([[1,3,4],[2,7],[5],[6]]),Tableau([[1,3,5],[2,4],[6],[7]]))
	@test schensted([5,2,7,1,3,8,6,4]) == (Tableau([[1,3,4],[2,6,8],[5,7]]),Tableau([[1,3,6],[2,5,7],[4,8]]))
	@test schensted([1]) == (Tableau([[1]]),Tableau([[1]]))
	@test schensted(Int[]) == (Tableau([[]]),Tableau([[]]))

	# bump
	tab = Tableau([[]])
	for x in [1,2,1,1,3,4,1,1]
		bump!(tab,x)
	end
	@test tab == Tableau([[1,1,1,1,1],[2,3,4]])

end


@testset "Kostka polynomials" begin
	R,t = PolynomialRing(ZZ, "t")

	# kostka polynomials
	@test kostka_polynomial([4],[1,1,1,1]) == t^6
	@test kostka_polynomial([4],[2,1,1]) == t^3
	@test kostka_polynomial([4],[2,2]) == t^2
	@test kostka_polynomial([4],[3,1]) == t
	@test kostka_polynomial([4],[4]) == one(R)
	@test kostka_polynomial([3,1],[1,1,1,1]) == t^5 + t^4 + t^3
	@test kostka_polynomial([3,1],[2,1,1]) == t^2 + t
	@test kostka_polynomial([3,1],[2,2]) == t
	@test kostka_polynomial([3,1],[3,1]) == one(R)
	@test kostka_polynomial([2,2],[1,1,1,1]) == t^4 + t^2
	@test kostka_polynomial([2,2],[2,1,1]) == t
	@test kostka_polynomial([2,2],[2,2]) == one(R)
	@test kostka_polynomial([2,1,1],[1,1,1,1]) == t^3 + t^2 + t
	@test kostka_polynomial([2,1,1],[2,1,1]) == one(R)
	@test kostka_polynomial([1,1,1,1],[1,1,1,1]) == one(R)
	@test kostka_polynomial([2,2],[3,1]) == zero(R)

	check = true
	for λ in partitions(5), μ in partitions(5)
		kp = kostka_polynomial(λ,μ)
		if kp(1) != length(semistandard_tableaux(λ,μ))
			check = false
			break
		end
	end
	@test check == true

	# charge
	@test charge([2,1,1,2,3,5,4,3,4,1,1,2,2,3]) == 8
	@test charge([2,5,4,1,3],true) == 3
	@test charge([1,3,2],true) == 2
	@test charge(Int[]) == 0

	@test charge(Tableau([[1,1,1,4], [2,2], [3]])) == 1
	@test charge(Tableau([[1,1,1,3], [2,2], [4]])) == 2
	@test charge(Tableau([[1,1,1,2], [2,4], [3]])) == 2
	@test charge(Tableau([[1,1,1,2], [2,3], [4]])) == 3
	@test charge(Tableau([[]])) == 0

	@test charge([Partition([2,2,2,2,2,2,2]),Partition([4,3,1,1]),Partition([3,2]),Partition([2])]) == 18
	@test charge([Partition([6,4,3,2]),Partition([5,2]),Partition([2])]) == 3
	@test charge([Partition([6,4,3,2]),Partition([4,3]),Partition([2])]) == 3

end


@testset "Schur polynomials" begin
	x = [string("x",string(i)) for i=1:3]
	S,x = PolynomialRing(ZZ, x)

	# schur_polynomial(λ, R)
	@test schur_polynomial(Partition([1]), S) == x[1]
	@test schur_polynomial(Partition([1,1]), S) == x[1]*x[2]
	@test schur_polynomial(Partition([2]), S) == x[1]^2 + x[2]^2 + x[1]*x[2]
	@test schur_polynomial(Partition([1,1,1]), S) == x[1]*x[2]*x[3]
	@test schur_polynomial(Partition([2,1]), S) == 2*x[1]*x[2]*x[3] + x[1]^2*x[2] + x[1]*x[2]^2 + x[1]^2*x[3] + x[1]*x[3]^2 + x[2]^2*x[3] + x[2]*x[3]^2
	@test schur_polynomial(Partition([3]), S) == x[1]*x[2]*x[3] + x[1]^2*x[2] + x[1]*x[2]^2 + x[1]^2*x[3] + x[1]*x[3]^2 + x[2]^2*x[3] + x[2]*x[3]^2 + x[1]^3 + x[2]^3 + x[3]^3
	@test schur_polynomial(Partition([]), S) == 1

	# schur_polynomial(λ, x)
	@test schur_polynomial(Partition([]), [x[1]]) == 1
	@test schur_polynomial(Partition([]), x[1:0]) == 1
	@test schur_polynomial(Partition([1]), x[1:0]) == 0

	check = true
	for n = 1:5
		x = [string("x",string(i)) for i=1:n]
		S,x = PolynomialRing(ZZ, x)
		for p in partitions(n)
			if schur_polynomial(p, x) != schur_polynomial(p, S)
				check = false
			end
		end
	end
	@test check == true

	#schur_polynomial(λ)
	@test schur_polynomial(Partition([])) == 1
	@test schur_polynomial(Partition([1]))(1) == 1

	#schur_polynomial(λ, n)
	@test schur_polynomial(Partition([]), 1) == 1
	@test schur_polynomial(Partition([]), 0) == 1
	@test schur_polynomial(Partition([3,2,1]), 0) == 0
	@test_throws ArgumentError schur_polynomial(Partition([3,2,1]), -1)

end


include("cartan_matrices.jl")
