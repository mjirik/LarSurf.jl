#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
using Test
using Logging
using Revise
using lario3d
using Plasm
using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation


@testset "Extract surface grid" begin

    segmentation = zeros(Int8, 5, 6, 7)

    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
    (VV, EV, FV, CV) = model
#     Plasm.View((V,[VV, EV, filteredFV]))

    expected_size = 2 * (obj_sz[1] * obj_sz[2] + obj_sz[2] * obj_sz[3] + obj_sz[1] * obj_sz[3])


    @test expected_size == expected_size
    # print(faces, "\n")
end
