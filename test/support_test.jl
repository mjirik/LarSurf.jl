
# # using Revise
using Test
using Logging
using LarSurf
using SparseArrays
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation
# Logging.configure(level==Logging.Debug)


# include("../src/LarSurf.jl")
# include("../src/block.jl")

@testset "array compare roll independent" begin
    @test LarSurf.array_equal_roll_invariant([1,2,3,4,5], [2,3,4,5,1])

end
