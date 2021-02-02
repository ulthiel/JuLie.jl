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
	@test quantum(6, one(QQ)) == QQ(6)

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
	@test gaussian_binomial(2,1,one(ZZ)) == 2

end
