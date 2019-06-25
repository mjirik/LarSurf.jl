
# using Revise
using Test
using Logging
using LarSurf
using SparseArrays
using Io3d
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation
# Logging.configure(level==Logging.Debug)


# include("../src/LarSurf.jl")
# include("../src/block.jl")

@testset "array compare roll independent" begin
    xystep = 1
    zstep = 1
    threshold = 4000;
    pth = Io3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
    datap = Io3d.read3d(pth)

    data3d = datap["data3d"]
    segmentation = data3d .> threshold


    block_size = [5,5,5]
    basicmodel, Flin, larmodel = LarSurf.get_surface_grid_per_block(segmentation, block_size; return_all=true)
    someV, topology = basicmodel
    filtered_bigFV = topology[1]
    # someV, filtered_bigFV = basicmodel
    bigV = someV
    # bigV, tmodel = larmodel
    # bigVV, bigEV, bigFV, bigCV = tmodel
    # return (bigV,[FVreduced])

    # Plasm.View(basicmodel)
    # Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

    FV = filtered_bigFV

    newBigV = LarSurf.Smoothing.smoothing_FV(bigV, FV)
    @test typeof(newBigV) == Array

    # Plasm.View((newBigV * 100,[filtered_bigFV]))
end
