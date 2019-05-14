
using Revise
using Test
using Logging
using lario3d
using SparseArrays
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "array compare roll independent" begin
    @test lario3d.array_equal_roll_invariant([1,2,3,4,5], [2,3,4,5,1])

end
