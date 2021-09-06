using JuLie
using BenchmarkTools

println("Semistandard tableaux")
@btime L=semistandard_tableaux(Partition(Int8[5,3,2]));
