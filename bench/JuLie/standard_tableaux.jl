using JuLie
using BenchmarkTools

println("Standard tableaux")
@btime L=standard_tableaux(Int8[10,8,3]);
