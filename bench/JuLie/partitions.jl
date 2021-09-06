using JuLie
using BenchmarkTools

println("Partitions")
@btime L=partitions(Int8(90));
