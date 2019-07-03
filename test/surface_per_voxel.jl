using Revise
using Test
using Logging
using SparseArrays
using Distributed
using LarSurf

@testset "Extract surface grid" begin
    segmentation = LarSurf.data234()
    verts, faces= LarSurf.get_surface_grid_per_voxel(segmentation; voxelsize_mm=[1,1,1])
    # verts are transposed, faces are in 2-D Array
    trifaces = LarSurf.triangulation(faces)

    # Visualization
    @test LarSurf.check_vf(verts, trifaces)

end
