#=
array3d_to_lar:
- Julia version: 
- Author: miros
- Date: 2019-01-14
=#
include("../src/plasm.jl")
include("../src/read.jl")
include("../src/surface.jl")
include("../src/representation.jl")
include("../src/import3d.jl")

## Artifical data
data3d = zeros(Int16,5,4,3)
data3d[2:4,2:3,2] .= 10
# data3d

voxelsize_mm = [0.5, 0.9, 0.8]
threshold=0

# Get vertices and count the voxesl (*4 face number)
verts, nvoxels = vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm)

# Create square faces

faces = create_square_faces(data3d, nvoxels, threshold)

new_verts, new_faces = keep_surface_faces(verts, faces)

verts = new_verts
faces = new_faces

# Triangulation

trifaces = triangulation(faces)

# Visualization
check_vf(verts, trifaces)
visualize_numbers(to_lar(verts, trifaces), 0.5)