using Test
using Logging
using Revise
using LarSurf
# Logging.configure(level==Logging.Debug)


# include("../src/LarSurf.jl")
# include("../src/block.jl")

@testset "to_csv" begin
    LarSurf.add_to_csv((:jedna=>[1], :dva=>[2]), "test1.csv")
    @test isfile("test1.csv")
    LarSurf.add_to_csv((:jedna=>1, :dva=>2), "test2.csv")
    @test isfile("test2.csv")
end
