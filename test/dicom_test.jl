#=
- Julia version: 1.1.0
- Author: Jirik
=#
# using Revise
using Test
using Logging
using LarSurf

@testset "Init and deinit" begin
# Dataset can be downloaded from here:
# https://www.ircad.fr/research/3d-ircadb-01/
# this is path where data on all my computers are stored
	dicomdir = homedir() * "/data/medical/orig/3Dircadb1.1/MASKS_DICOM/portalvein/"

	datap = LarSurf.read_dicom_dir(dicomdir, "image_")
	data3d = datap["data3d"]
	voxelsize_mm = datap["voxelsize_mm"]
	@test size(data3d, 2) == 512
	@test size(data3d, 3) == 512
	@test voxelsize_mm[2] == voxelsize_mm[3]

end
