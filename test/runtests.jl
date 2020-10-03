using Test
using Combinatorics
import Nemo: ZZ, QQ

@testset "Basic enumerative functions" begin

  # @test fac(29) == ZZ(8841761993739701954543616000000)
  # @test fac(29, alg="gmp") == ZZ(8841761993739701954543616000000)
  # @test fac(29, alg="flint") == ZZ(8841761993739701954543616000000)
  #
  # @test rfac(17, 29) == ZZ(5717316930763999008140455952929259520000000)
  #
  # @test bin(199,117) == ZZ(2089529072965460843319142283156535370524645516350358395240)
  # @test bin(199,117,alg="gmp") == ZZ(2089529072965460843319142283156535370524645516350358395240)
  # @test bin(199,117,alg="flint") == ZZ(2089529072965460843319142283156535370524645516350358395240)
  #
  # @test fib(211) == ZZ(55835073295300465536628086585786672357234389)
  # @test fib(211, alg="gmp") == ZZ(55835073295300465536628086585786672357234389)
  # @test fib(211, alg="flint") == ZZ(55835073295300465536628086585786672357234389)
  #
  # @test lucas(231) == ZZ(1888621362467059762119226660462223993033685748724)
  #
  # @test catalan(87) == ZZ(16435314834665426797069144960762886143367590394940)
  # @test catalan(87, alg="binomial") == ZZ(16435314834665426797069144960762886143367590394940)
  # @test catalan(87, alg="iterative") == ZZ(16435314834665426797069144960762886143367590394940)
  #
  # @test bell(47) == ZZ(37450059502461511196505342096431510120174682)
  #
  # @test stirling1(119,97) == ZZ(231393604360614503792428283097412982860076938212225481588634166)
  #
  # @test stirling2(117,101) == ZZ(52573293149721609368885842841453741018410117476)
  #
  # @test num_partitions(991) == ZZ(16839773100833956878604913215477)
  #
  # @test euler(54) == ZZ(-7546659939008739098061432565889736744212240024711699858645581)

  # In Nemo already
  #@test harmonic(55) == QQ(251499286680120823312889)//QQ(54749786241679275146400)

  # In Nemo already
  #@test bernoulli(54) == QQ(29149963634884862421418123812691)//QQ(798)

end



@testset "Partitions" begin

  # Unrestricted partitions
  N = 1:22
  check = true
  for n in N
    for a in [ "zs1", "ks", "m" ]
      P = partitions(n,alg=a)
      if length(P) != num_partitions(n)
        check = false
        break
      end
      if P != unique(P)
        check = false
        break
      end
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

  #k-restricted partitions
  N = 1:22
  check = true
  for n in N
    for k = 0:n+1
      P = partitions(n,k)
      if length(P) != num_partitions(n,k)
        check = false
        break
      end
      if P != unique(P)
        check = false
        break
      end
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

end
