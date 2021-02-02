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

	# union
	msp = Multiset_partition()
	msp = union(msp,Partition([1]),Partition([2]),Partition([3]))
	@test msp == Multiset_partition([1],[2],[3])
	msp = union(msp,Partition([3]),Partition([3]))
	@test msp == Multiset_partition([1],[2],[3],[3],[3])
	union(msp,Partition([3]))
	@test msp == Multiset_partition([1],[2],[3],[3],[3])


	# union!
	msp = Multiset_partition()
	union!(msp,Partition([1]),Partition([2]),Partition([3]))
	@test msp == Multiset_partition([1],[2],[3])
	union!(msp,Partition([3]),Partition([3]))
	@test msp == Multiset_partition([1],[2],[3],[3],[3])

	# getindex
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

	#copy
	msp = Multiset_partition([2],[2],[8,7,6])
	mspc = copy(msp)
	@test msp == mspc
	push!(msp, Partition([2]))
	@test msp != mspc


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
