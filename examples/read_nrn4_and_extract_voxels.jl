#=
read_nrn4_and_extract_voxels.jl:
- Julia version: 1.1
- Author: Jirik
- Date: 2019-03-05
=#

# include("../src/LarSurf.jl")
using Revise
using Plasm
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation
using LarSurf

pth = LarSurf.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = LarSurf.read3d(pth)

data3d = datap["data3d"]
voxelsize_mm = datap["voxelsize_mm"]
threshold = 4000

vertices, nvoxels = LarSurf.vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm, threshold)
voxels = LarSurf.create_cuboid_voxels(data3d, nvoxels, threshold)

voxels_linear01 = LarSurf.ind_to_sparse(hcat(voxels), prod(size(data3d)), 1)