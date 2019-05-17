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
    larmodel1 = (V,[VV, EV, filteredFV])

    @test lario3d.check_LARmodel(larmodel1)
    # Plasm.View(larmodel1)
end



@testset "Extract surface grid and check euler" begin

    segmentation = lario3d.data234()
    # reducedLARmodel, Flin, (V, model) = lario3d.get_surface_grid_old(segmentation; return_all=true)
    reducedLARmodel, Flin, (V, model) = lario3d.get_surface_grid(segmentation; return_all=true)

    (VV, EV, FV, CV) = model
    filteredFV = reducedLARmodel[2][1]
    larmodel1 = (V,[VV, EV, filteredFV])

    # Plasm.View(larmodel1)
    display(filteredFV)

    @test lario3d.check_surface_euler(filteredFV)

end

@testset "Extract surface grid per block full" begin


    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    segmentation = lario3d.data234()
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))
    # just for visualization
    data_size = lario3d.size_as_array(size(segmentation))
    V, (VV, EV, FV, CV) = Lar.cuboidGrid(data_size, true)
    Fchar = lario3d.__grid_get_surface_Fchar_per_block(segmentation, [2,2,2])

    V1, topology1 = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
    # (VV, EV, FV, CV) = model
    larmodel1 = (V,[VV, EV, topology1[1]])
    @test lario3d.check_LARmodel(larmodel1)
    @test lario3d.check_surface_euler(topology1[1])
    # Plasm.View(larmodel1)

    # second implementation
    V2, FV2 = lario3d.grid_Fchar_to_V_FVreduced(Fchar, size(segmentation))
    larmodel2 = (V2,[VV, EV, FV2])
    @test lario3d.check_LARmodel(larmodel2)
    @test lario3d.check_surface_euler(FV2)
    # Plasm.view( Plasm.numbering(.6)(larmodel2) )

    # third implementation
    V3, FV3 = lario3d.grid_Fchar_to_Vreduced_FVreduced_old(Fchar, data_size)
    larmodel3 = (V3, [FV3])
    @test lario3d.check_LARmodel(larmodel3)
    @test lario3d.check_surface_euler(FV3)
    # Plasm.view(larmodel3)

    V4, FV4 = lario3d.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size)
    larmodel4 = (V4, [FV4])
    @test lario3d.check_LARmodel(larmodel4)
    @test lario3d.check_surface_euler(FV4)
    # VV3 = [[i] for i=1:size(V3,2)]
    # Plasm.view((V3, [VV3, FV3]))
    # Plasm.view(larmodel4)

end

@testset "Extract surface grid per block reduced FV" begin

    segmentation = lario3d.data234()
    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    # obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    larmodel1 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
    @test lario3d.check_LARmodel(larmodel1)
    @test lario3d.check_surface_euler(larmodel1[2][1])
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
    @test lario3d.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)

    larmodel1 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])
    @test lario3d.check_LARmodel(larmodel1)
    @test lario3d.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)

end

@testset "Get Flin test" begin

    segmentation = lario3d.data234()
    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    # obj_sz = [2, 2, 2]
    block_size = [2,2,2]

    Flin = lario3d.__grid_get_surface_Fchar_per_block(segmentation, block_size)
    # Slin, oneS, b3 = lario3d.grid_get_surface_Flin_loc_fixed_block_size(segmentation, [2,2,2])
    Flin_loc, offsets, blocks_number_axis, larmodel1 = lario3d.grid_get_surface_Bchar_loc_fixed_block_size(segmentation, block_size)
    Flin, new_data_size = lario3d.__grid_get_surface_Fchar_per_fixed_block_size(segmentation, block_size)
    larmodel1 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced_fixed_block_size(segmentation, block_size)
    @test lario3d.check_LARmodel(larmodel1)
    @test lario3d.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)
end
