using JuLie
using BenchmarkTools

println("Semistandard tableaux")
@btime L=semistandard_tableaux(Partition(Int8[6,3,2]));
