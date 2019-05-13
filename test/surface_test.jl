#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
using Revise
using Test
using Logging
using lario3d
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


@testset "Extract surface grid" begin

    segmentation = zeros(Int8, 5, 6, 7)

    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    # reducedLARmodel, Flin, (V, model) = lario3d.get_surface_grid_old(segmentation; return_all=true)
    reducedLARmodel, Flin, (V, model) = lario3d.get_surface_grid(segmentation; return_all=true)

    (VV, EV, FV, CV) = model
    filteredFV = reducedLARmodel[2][1]
    Plasm.View((V,[VV, EV, filteredFV]))

    # expected_size = 2 * (obj_sz[1] * obj_sz[2] + obj_sz[2] * obj_sz[3] + obj_sz[1] * obj_sz[3])
    #
    #
    # @test expected_size == expected_size
    # print(faces, "\n")
end

@testset "Extract surface grid per block full" begin

    segmentation = zeros(Int8, 5, 6, 7)
    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]

    segmentation = zeros(Int8, 2, 3, 4)

    segmentation[1:2,2:3,3:4] .= 1
    obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))
    # just for visualization
    data_size = lario3d.size_as_array(size(segmentation))
    V, (VV, EV, FV, CV) = Lar.cuboidGrid(data_size, true)
    Fchar = lario3d.__grid_get_surface_Fchar_per_block(segmentation, [2,2,2])

    V1, topology1 = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
    # (VV, EV, FV, CV) = model
    larmodel1 = (V,[VV, EV, topology1[1]])
    @test lario3d.check_LARmodel(larmodel1)
    Plasm.View(larmodel1)

    # second implementation
    V2, FV2 = lario3d.grid_Fchar_to_V_FVreduced(Fchar, size(segmentation))
    larmodel2 = (V2,[VV, EV, FV2])
    @test lario3d.check_LARmodel(larmodel2)
    Plasm.view( Plasm.numbering(.6)(larmodel2) )

    # third implementation
    V3, FV3 = lario3d.grid_Fchar_to_Vreduced_FVreduced_old(Fchar, data_size)
    larmodel3 = (V3, [FV3])
    @test lario3d.check_LARmodel(larmodel3)
    Plasm.view(larmodel3)

    V4, FV4 = lario3d.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size)
    larmodel4 = (V4, [FV4])
    @test lario3d.check_LARmodel(larmodel4)
    # VV3 = [[i] for i=1:size(V3,2)]
    # Plasm.view((V3, [VV3, FV3]))
    Plasm.view(larmodel4)

end

@testset "Extract surface grid per block reduced FV" begin

    segmentation = zeros(Int8, 5, 6, 7)
    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]

    segmentation = zeros(Int8, 2, 3, 4)
    segmentation[1:2,2:3,3:4] .= 1
    obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    larmodel1 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
    @test lario3d.check_LARmodel(larmodel1)
    # Plasm.View(larmodel1)

end

@testset "Extract surface grid per block reduced FV and V" begin

    segmentation = zeros(Int8, 5, 6, 7)
    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]

    segmentation = zeros(Int8, 2, 3, 4)

    segmentation[1:2,2:3,3:4] .= 1
    obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    larmodel1 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced_old(segmentation, [2,2,2])
    @test lario3d.check_LARmodel(larmodel1)
    # Plasm.View(larmodel1)

    larmodel1 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])
    @test lario3d.check_LARmodel(larmodel1)
    # Plasm.View(larmodel1)

end

@testset "Get Flin test" begin

    segmentation = zeros(Int8, 5, 6, 7)
    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]

    segmentation = zeros(Int8, 2, 3, 4)

    segmentation[1:2,2:3,3:4] .= 1
    obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    Flin = lario3d.__grid_get_surface_Fchar_per_block(segmentation, [2,2,2])
    # Flin = lario3d.__grid_get_surface_Fchar_per_fixed_size_block(segmentation, [2,2,2])
    # @test lario3d.check_LARmodel(larmodel1)
    # Plasm.View(larmodel1)
end
