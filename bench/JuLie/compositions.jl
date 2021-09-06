using JuLie
using BenchmarkTools

println("Compositions")
@btime L=compositions(Int8(26));
