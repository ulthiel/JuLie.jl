using AbstractAlgebra: matrix, zero_matrix

@testset "Cartan matrices" begin

    @test !is_cartan_matrix(zero_matrix(ZZ, 2, 2))
    @test !is_cartan_matrix(zero_matrix(ZZ, 2, 2))

    @test CartanMatrix("A1") == matrix(ZZ, 1, 1, [2])
    @test CartanMatrix("A1~") == matrix(ZZ, 2, 2, [2 -2 ; -2 2])
    @test CartanMatrix("A2") == matrix(ZZ, 2, 2, [2 -1 ; -1 2])
    @test CartanMatrix("A3") == matrix(ZZ, 3, 3, [2 -1 0; -1 2 -1 ; 0 -1 2])

    @test_throws DomainError CartanMatrix(zero_matrix(ZZ, 2, 2))
    @test_throws ArgumentError CartanMatrix("K2")

end
