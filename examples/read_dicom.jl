# using LarSurf
using DICOM
using Distributed
if nprocs() == 1
    addprocs(3)
end
include("dicom_support.jl")
# Dataset can be downloaded from here:
# https://www.ircad.fr/research/3d-ircadb-01/
# this is path where data on all my computers are stored
dicomdir = homedir() * "/data/medical/orig/3Dircadb1.1/MASKS_DICOM/portalvein/"

datap = read_dicom_dir(dicomdir, "image_")

segmentation = datap["data3d"]
voxelsize_mm = datap["voxelsize_mm"]
using LarSurf
tm = time()
@everywhere using LarSurf
@everywhere using Distributed
tm = time() - tm
@info "everywhere time: $tm"

# tm = time()
# @everywhere using LarSurf
# @everywhere using Distributed
# tm = time() - tm
# @info "everywhere time second: $tm"
# 
block_size = [64, 64, 64]
setup_time = @elapsed LarSurf.lsp_setup(block_size)
println("setup time: $setup_time")

tmd = @timed larmodel = LarSurf.lsp_get_surface(segmentation; voxelsize=voxelsize_mm)
val, tm, mem, gc = tmd
println("Total time: $tm")
V, FV = larmodel
FVtri = LarSurf.triangulate_quads(FV)


@info "Loading ViewerGL"
using ViewerGL
ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])



FVtri = LarSurf.triangulate_quads(FV)
# tm1 = @elapsed EV1 = LarSurf.Smoothing.get_EV_quads(FVtri)
# tm2 = @elapsed EV2 = LarSurf.Smoothing.get_EV_quads2(FVtri)
# @info "time get EV" tm1 tm2
# Plasm.view(val)
ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,0,1,1))
    # ViewerGL.GLGrid(V,EV1,ViewerGL.Point4d(.9,0,.9,0.9))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])

iterations = 3
Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, iterations)

ViewerGL.VIEW([
    ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,0,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])


iterations = 3
Vtaubin = LarSurf.Smoothing.smoothing_FV_taubin(V, FVtri, 0.4, -0.35, iterations)

ViewerGL.VIEW([
    ViewerGL.GLGrid(Vtaubin,FVtri,ViewerGL.Point4d(1,0,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
