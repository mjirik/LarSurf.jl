

"""
The output is in different form from the other functions
Here voxels are tranposed and faces are in 2-D array.
"""
function get_surface_grid_per_voxel(data3d::Array; voxelsize_mm::Array=[1,1,1])
    # Get vertices and count the voxesl (*4 face number)
    verts, nvoxels = LarSurf.vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm)

    # Create square faces

    threshold = 0
    faces = LarSurf.create_square_faces(data3d, nvoxels, threshold)

    new_verts, new_faces = LarSurf.keep_surface_faces(verts, faces)

    verts = new_verts
    faces = new_faces

    return verts, faces

end


# function continue(verts, faces)
    # # Triangulation
    #
    # trifaces = LarSurf.triangulation(faces)
    #
    # # Visualization
    # LarSurf.check_vf(verts, trifaces)
    #
    # V, EV, FE = LarSurf.to_lar(verts, trifaces)
    #
    # EVc = Lar.cop2lar(EV)
    # Vnew = convert(Array, transpose(V))
    # VV = [i for i=1:length(Vnew)]
    # return Vnew, [VV, EV]
# end
