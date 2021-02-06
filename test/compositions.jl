@testset "Compositions" begin

	C = compositions(5)
	@test length(C) == num_compositions(5)
	check = true
	for c in C
		if sum(c) != 5
			check = false
			break
		end
	end
	@test check

end
