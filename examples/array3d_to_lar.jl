#=
array3d_to_lar:
- Julia version:
- Author: miros
- Date: 2019-01-14
=#
include("../src/lario3d.jl")
# include("../src/plasm.jl")
# include("../src/read.jl")
# include("../src/surface.jl")
# include("../src/representation.jl")
# include("../src/import3d.jl")
# lario3d.

## Artifical data
data3d = zeros(Int16,5,4,3)
data3d[2:4,2:3,2] .= 10
# data3d

voxelsize_mm = [0.5, 0.9, 0.8]
threshold=0

# Get vertices and count the voxesl (*4 face number)
verts, nvoxels = lario3d.vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm)

# Create square faces

faces = lario3d.create_square_faces(data3d, nvoxels, threshold)

new_verts, new_faces = lario3d.keep_surface_faces(verts, faces)

verts = new_verts
faces = new_faces

# Triangulation

trifaces = lario3d.triangulation(faces)

# Visualization
lario3d.check_vf(verts, trifaces)

V, EV, FE = to_lar(verts, trifaces)
# this does not work yet
# lario3d.visualize_numbers((V, EV, FE), 0.5)
