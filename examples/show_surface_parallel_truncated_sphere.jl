using ViewerGL
using Distributed
if nprocs() == 1
    addprocs(3)
end
using Logging
using SparseArrays
@everywhere using LarSurf

block_size = [20, 20, 20]
LarSurf.lsp_setup(block_size)

segmentation = LarSurf.generate_truncated_sphere(10)

V, FV = LarSurf.lsp_get_surface(segmentation)
FVtri = LarSurf.triangulate_quads(FV)
objlines = LarSurf.Lar.lar2obj(V, FVtri, "tetris_tri.obj")

ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])

Vs = LarSurf.Smoothing.smoothing_FV_taubin(V, FV, 0.4, -0.3, 50)

ViewerGL.VIEW([
    ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])

objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "tetris_tri_taubin.obj")
