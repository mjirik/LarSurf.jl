
using Test
using Logging
using Revise
using lario3d
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

segmentation = zeros(Int8, 5, 6, 7)
segmentation[2:5,2:5,2:6] .= 1
obj_sz = [4, 4, 5]

segmentation = zeros(Int8, 2, 3, 4)

segmentation[1:2,2:3,3:4] .= 1
obj_sz = [2, 2, 2]

# Warm up
larmodel1 = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
larmodel2 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
larmodel3 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])

println("Fchar, V and FV computation")
@time larmodel1 = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
@time larmodel2 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
@time larmodel3 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])

Fchar = lario3d.__grid_get_surface_Fchar_per_block(segmentation, [2,2,2])
data_size = lario3d.size_as_array(size(segmentation))
println("just V and FV computation")
@time lario3d.grid_Fchar_to_V_FVfulltoreduced(Fchar, data_size)
@time lario3d.grid_Fchar_to_V_FVreduced(Fchar, data_size)
@time lario3d.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size)
