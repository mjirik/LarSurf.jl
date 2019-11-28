
# using Revise
using Test
using Logging
using LarSurf

@testset "Triangulate quad" begin
    FV = [[1,2,3,4], [4,5,6,7]]
    FVtri = LarSurf.triangulate_quads(FV)
    @test size(FVtri[1],1) == 3
end
