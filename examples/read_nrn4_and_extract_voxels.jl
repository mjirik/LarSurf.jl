#=
read_nrn4_and_extract_voxels.jl:
- Julia version: 1.1
- Author: Jirik
- Date: 2019-03-05
=#

# include("../src/lario3d.jl")
using Revise
using Plasm
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation
using lario3d

pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = lario3d.read3d(pth)

data3d = datap["data3d"]
voxelsize_mm = datap["voxelsize_mm"]
threshold = 4000

vertices, nvoxels = lario3d.vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm, threshold)
voxels = lario3d.create_cuboid_voxels(data3d, nvoxels, threshold)

voxels_linear01 = lario3d.ind_to_sparse(hcat(voxels), prod(size(data3d)), 1)