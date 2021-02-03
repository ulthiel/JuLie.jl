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

	# An example from https://www2.math.upenn.edu/~peal/polynomials/kostkaFoulkes.htm
	@test kostka_polynomial([4,2,1],[3,2,1,1]) == t^3 + 2*t^2 + t

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
	@test charge([3,2]) == 0
	@test charge([3,1],true) == 0
	@test charge([2,5,4,1,3],true) == 3
	@test charge([1,3,2],true) == 2
	@test charge(Int[]) == 0

	@test charge(Tableau([[1,1,1,4], [2,2], [3]])) == 1
	@test charge(Tableau([[1,1,1,3], [2,2], [4]])) == 2
	@test charge(Tableau([[1,1,1,2], [2,4], [3]])) == 2
	@test charge(Tableau([[1,1,1,2], [2,3], [4]])) == 3
	@test charge(Tableau(Array{Int,1}[])) == 0

	@test charge([Partition([2,2,2,2,2,2,2]),Partition([4,3,1,1]),Partition([3,2]),Partition([2])]) == 18
	@test charge([Partition([6,4,3,2]),Partition([5,2]),Partition([2])]) == 3
	@test charge([Partition([6,4,3,2]),Partition([4,3]),Partition([2])]) == 3

end
