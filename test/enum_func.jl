@testset "Enumerative functions" begin

	# catalan
	@test catalan(ZZ(0)) == ZZ(1)
	@test catalan(ZZ(1)) == ZZ(1)
	@test catalan(3) == ZZ(5)
	@test catalan(ZZ(87)) == ZZ(16435314834665426797069144960762886143367590394940)

	# stirling
	@test stirling1(ZZ(119),ZZ(97)) == ZZ(231393604360614503792428283097412982860076938212225481588634166)
	@test stirling1(1,1) == ZZ(1)
	@test stirling2(ZZ(117),ZZ(101)) == ZZ(52573293149721609368885842841453741018410117476)
	@test stirling2(3,2) == ZZ(3)

	# lucas
	@test lucas(ZZ(201)) == ZZ(1015116040150328233272520834523487973612876)
	@test lucas(2) == ZZ(3)

end
