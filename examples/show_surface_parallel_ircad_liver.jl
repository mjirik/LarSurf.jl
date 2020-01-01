using ViewerGL
using Distributed
using Pio3d
if nprocs() == 1
    addprocs(3)
end
using LarSurf

LarSurf.lsp_setup([64, 64, 64])

# segmentation = LarSurf.generate_truncated_sphere(10)
pth = Pio3d.datasets_join_path("medical/orig/3Dircadb1.1/MASKS_DICOM/liver")
datap = Pio3d.read3d(pth)
segmentation = datap["data3d"]
voxelsize_mm = datap["voxelsize_mm"]

V, FV = LarSurf.lsp_get_surface(segmentation, voxelsize_mm)
FVtri = LarSurf.triangulate_quads(FV)
objlines = LarSurf.Lar.lar2obj(V, FVtri, "tetris_tri.obj")

# ViewerGL.VIEW([
#     ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])

Vs = LarSurf.Smoothing.smoothing_FV_taubin(V, FV, 0.5, -0.2, 40)

ViewerGL.VIEW([
    ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])

objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "liver.obj")
