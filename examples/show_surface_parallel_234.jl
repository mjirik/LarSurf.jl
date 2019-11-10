
using ViewerGL
using Distributed
if nprocs() == 1
    addprocs(3)
	@info "adding 3 more CPUs"
end
# using Revise
using Test
using Logging
using SparseArrays
@everywhere using LarSurf

    block_size = [2, 2, 2]
    segmentation = LarSurf.data234()

    LarSurf.lsp_setup(block_size)

    # @debug "Setup done"
    larmodel = LarSurf.lsp_get_surface(segmentation)
	V, FV = larmodel
    # @test LarSurf.check_surface_euler(larmodel[2])
    FVtri = LarSurf.triangulate_quads(FV)
    # @test LarSurf.check_surface_euler(FVtri)

# ViewerGL.VIEW([
#     ViewerGL.GLGrid(V,FV,ViewerGL.Point4d(1,1,1,0.1))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])
ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
