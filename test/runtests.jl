using Test
using Combinatorics
import Nemo: ZZ, QQ

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
  check = true
  N = 0:30
  for n in N
    # go through all algorithms
    for a in [ "zs1", "ks", "m" ]
      P = partitions(n,alg=a)
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
  N = 0:30
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

end
