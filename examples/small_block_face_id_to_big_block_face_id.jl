#=
small_block_face_id_to_big_block_face_id:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays

data_size = [2,3,4]
block_size = [2,2,2]
offset = [0, 0, 0]



# data_size = [2,3,4]
# block_size = [2,2,2]
# offset = [0, 0, 0]
# fid = 2
# expected_big_fid = 2
# fid = 4
# expected_big_fid = 6
# fid = 13
# expected_big_fid = 37
# fid = 20
# expected_big_fid = 54
fid = 20

face_cart, axis = LarSurf.grid_face_id_to_cartesian(block_size, fid)
# face_cart

big_fids = LarSurf.get_face_ids_from_cube_in_grid(data_size, face_cart + offset, false)
big_fid = big_fids[axis]


function sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset, fid)
    face_cart, axis = LarSurf.grid_face_id_to_cartesian(block_size, fid)
    # face_cart

    big_fids = LarSurf.get_face_ids_from_cube_in_grid(data_size, face_cart + offset, false)
    big_fid = big_fids[axis]
    return big_fid
end


big_fid = sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset, fid)
big_fid
