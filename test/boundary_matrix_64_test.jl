using Test
using Logging
using LarSurf

@testset "Tests get boundary with size 64.5 " begin
    grid_size = [64,64,64]
    # For faster calculation the boundary matrices are stored in memory and in file.
    # For now we would like to supress using of this preprocessed matrix.
    LarSurf.set_param(
        boundary_allow_memory=false,
        boundary_allow_read_files=false,
        boundary_allow_write_files=false
        )

    @time b3a, larmodel_a = LarSurf.get_boundary3(grid_size)


    n_faces = LarSurf.grid_number_of_faces(grid_size)
    n_voxels = prod(grid_size)
    # println("$(size(b3a)) , sum $(sum(b3a))")

    @test sum(b3a) == 6*n_voxels # total number of nonzeros
    @test size(b3a) == (n_voxels, n_faces)

end
