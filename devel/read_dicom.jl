# using LarSurf
using DICOM
include("dicom_support.jl")
# Dataset can be downloaded from here:
# https://www.ircad.fr/research/3d-ircadb-01/
# this is path where data on all my computers are stored
dicomdir = homedir() * "/data/medical/orig/3Dircadb1.1/MASKS_DICOM/portalvein/"

datap = read_dicom_dir(dicomdir, "image_")

segmentation = datap["data3d"]
voxelsize_mm = datap["voxelsize_mm"]
using LarSurf
@everywhere using LarSurf
@everywhere using Distributed
block_size = [64, 64, 64]
setup_time = @elapsed LarSurf.lsp_setup(block_size)
println("setup time: $setup_time")

tmd = @timed larmodel = LarSurf.lsp_get_surface(segmentation; voxelsize=voxelsize_mm)
val, tm, mem, gc = tmd
println("Total time: $tm")
V, FV = larmodel
FVtri = LarSurf.triangulate_quads(FV)


ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
