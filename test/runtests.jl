using Test
using JuLie

if isempty(ARGS)
    tests = [
        "combinatorics/compositions.jl"
    ]
else
    tests = ARGS
end

for test in tests
    include(test)
end
