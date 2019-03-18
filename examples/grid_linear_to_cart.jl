#=
grid_linear_to_cart:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-17
=#

grid_size= [2, 3, 4]

cube_carthesian_position = [2,2,2]
i, j, k = cube_carthesian_position
# i, j, k = [2,2,2]


function voxel_carthesian_grid_to_ind(grid_size, carthesian)
    sz1,sz2,sz3 = grid_size
    trf = 0
    ind = (sz2 * sz3) * (i - 1 + trf)  + (j - 1) * sz3 + k
    return ind
end

function voxel_grid_ind_to_carthesian(grid_size, ind)
#     ind = (sz2 * sz3) * (i - 1)  + (j - 1) * sz3 + k
    sz1,sz2,sz3 = grid_size
    layer = sz2*sz3
    ir = div(ind, layer) + 1
    rest1 = mod(ind, layer)
#     println("rest1 ", rest1)
    row = sz3
    jr = div(rest1, row) + 1
    rest2 = mod(rest1, row)
    kr = rest2
    return [ir, jr, kr]
end

function grid_x_face_to_carthesian(grid_size, ind)
    return voxel_grid_ind_to_carthesian(grid_size, ind)
end

function grid_y_face_to_carthesian(grid_size, ind)
#     f20 = nax1 +
#         (sz2 + 1) * sz3 * (i - 1 + trf)  + (j - 1 + trf) * sz3 + k
    sz1,sz2,sz3 = grid_size
    nax1 = (1 + sz1) * sz2 * sz3
    ind = ind - nax1

    layer = (sz2 + 1) * sz3
    ir = div(ind, layer) + 1
    rest1 = mod(ind, layer)

    jr = div(rest1, sz3) + 1
    rest2 = mod(rest1, sz3)
    kr = rest2
    return [ir, jr, kr]
end

function grid_z_face_to_carthesian(grid_size, ind)
#     nax3_layer = (sz3 + 1) * sz2 * (i - 1)
#     nax3_row = (j - 1) * (sz3 + 1)
#     f30 = nax1 +  nax2 +
#         nax3_layer + nax3_row  + k + trf
    sz1,sz2,sz3 = grid_size
    nax1 = (1 + sz1) * sz2 * sz3
    nax2 = sz1 * (1 + sz2) * sz3
    ind = ind - nax1 - nax2

    layer = (sz3 + 1) * sz2
    ir = div(ind, layer) + 1
    rest1 = mod(ind, layer)

    row = (sz3 + 1)
    jr = div(rest1, row) + 1
    rest2 = mod(rest1, row)
    kr = rest2
    return [ir, jr, kr]
end


# grid_size = sz
# sz1,sz2,sz3 = grid_size
# trf = 0
# ind = (sz2 * sz3) * (i - 1 + trf)  + (j - 1) * sz3 + k

# nax1 = (1 + sz1) * sz2 * sz3
ind = voxel_carthesian_grid_to_ind(sz, [2,2,2])
println("linear index: ", ind)

ir, jr, kr = voxel_grid_ind_to_carthesian(sz, ind)

println("carthesian index: ", ir, " ", jr, " ", kr)

#####################################


function grid_face_id_to_cartesian(grid_size, fid)
    sz1,sz2,sz3 = grid_size
    nax1 = (1 + sz1) * sz2 * sz3
    nax2 = sz1 * (1 + sz2) * sz3


    if fid <= nax1
        # x-face it is the same index as voxel index
        axis = 1
        voxel_cart = grid_x_face_to_carthesian(grid_size, fid)

    elseif fid <= (nax1 + nax2)
        # y-face
        axis = 2
        voxel_cart = grid_y_face_to_carthesian(grid_size, fid)
    else
        # z-face
        axis = 3
        voxel_cart = grid_z_face_to_carthesian(grid_size, fid)
    end
    return voxel_cart, axis
end

# this is for grid_size = [2,3,4] description of voxel_cart = [2,2,2]
grid_size= [2, 3, 4]
fid = 18
fid = 90
fid = 58

voxel_cart, axis = grid_face_id_to_cartesian(grid_size, fid)
println("voxel cart: ", voxel_cart, ", axis: ", axis)

# i, j, k = cube_carthesian_position
#
# f10 = (sz2 * sz3) * (i - 1 + trf)  + (j - 1) * sz3 + k
# @debug ("number of 1st axis faces: ", nax1, ", ")
# f20 = nax1 +
#     (sz2 + 1) * sz3 * (i - 1)  + (j - 1 + trf) * sz3 + k
#
# @debug ("2st axis faces: ", nax2, ", ")
# nax3_layer = (sz3 + 1) * sz2 * (i - 1)
# nax3_row = (j - 1) * (sz3 + 1)
# @debug ("3st axis faces in one layer and in one row: ",
#     nax3_layer, " ", nax3_row,  "\n")
# f30 = nax1 +  nax2 +
#     nax3_layer + nax3_row  + k + trf
