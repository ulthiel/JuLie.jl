@testset "combinatorics/compositions.jl" begin

    # Check some stupid cases
    @test num_compositions(0,0) == 1
    @test num_compositions(0,1) == 0
    @test num_compositions(1,0) == 0
    @test num_compositions(0) == 1

    # First few number of compositions from https://oeis.org/A011782
    nums = [1, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648, 4294967296, 8589934592]

    # Check if num_compositions is correct in these examples
    @test [num_compositions(n) for n=0:length(nums)-1] == nums

    # Complete check of compositions for small cases
    for n=0:5

        # We'll piece together all compositions of n by the compositions
        # of n into k parts for 0 <= k <= n
        allcomps = []
        for k=0:n
            C = compositions(n,k)

            @test length(C) == num_compositions(n,k)

            check = true

            # Check if each composition consists of k parts and sums up to n
            for c in C
                if length(c) != k
                    check = false
                    break
                end
                if sum(c) != n
                    check = false
                    break
                end
            end

            # Check if all compositions distinct
            if C != unique(C)
                check = false
            end

            @test check

            append!(allcomps, C)
        end

        # All compositions need to be distinct
        @test allcomps == unique(allcomps)

        # Number of compositions needs to be correct
        @test length(allcomps) == num_compositions(n)

        # Finally, check compositions(n) function
        allcomps2 = compositions(n)
        @test allcomps2 == unique(allcomps2)
        @test Set(allcomps) == Set(allcomps2)
    end

end
