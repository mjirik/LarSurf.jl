using Test
using Logging
using Revise
using lario3d
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "to_csv" begin
    lario3d.add_to_csv((:jedna=>[1], :dva=>[2]), "test1.csv")
    @test isfile("test1.csv")
    lario3d.add_to_csv((:jedna=>1, :dva=>2), "test2.csv")
    @test isfile("test2.csv")
end
