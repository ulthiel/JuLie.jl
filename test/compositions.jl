@testset "Compositions" begin

	for n=0:6
		C = compositions(n)
		@test length(C) == num_compositions(n)
		check = true
		for c in C
			if sum(c) != n
				check = false
				break
			end
		end
		if C != unique(C)
			check = false
		end
		@test check
	end

end
