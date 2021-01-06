using Test
#using Combinatorics
import Nemo: ZZ, QQ
import AbstractAlgebra: LaurentPolynomialRing

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
		# check that partititons are really partitions of n
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
			# check that partititons are really partitions of n
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
			# check that partititons are really partitions of n
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
				# check that partititons are really partitions of n
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

end

@testset "Multi-partitions" begin

	# multi-set-partitions
	check = true
	N = 0:15
	for n in N
		MP = multisetpartitions(n)
		# check that all multisetpartitions are distinct
		if MP != unique(MP)
			check = false
			break
		end
		# check that multisetpartititons are really multisetpartitions of n
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
	end
	@test check==true

	# k-restricted multisetpartitions
	check = true
	N = 0:15
	K = 1:15
	for n in N
		for k in K
			MP = multisetpartitions(n,k)
			# check that all multisetpartitions are distinct
			if MP != unique(MP)
				check = false
				break
			end
			# check that all multisetpartititons are really multisetpartitions of n
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
			if length(MP) !=0 && unique([ length(mp) for mp in MP ]) != [k]
				check = false
				break
			end
		end
	end
	@test check==true

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
end


@testset "Tableaux" begin
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
	weights = [[1,1,1,1,1,1,1,1,1,1],[3,0,2,0,0,5],[4,3,2,1,0]]
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
			println(length(SST))
		end
	end
	@test check==true


	# standard_tableaux(s::Partition)
	check = true
	for i=1:10
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
			if length(ST)!=hook_length_formula(s)
				check = false
				break
			end
		end
	end
	@test check==true
end
