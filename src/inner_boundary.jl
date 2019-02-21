import SparseArrays.spzeros

function inner_boundary_filter(shape)
    if shape == [3, 3]
        ibf = _inner_boundary33()
    elseif shape == [3, 3, 3]
        ibf = _inner_boundary333()
    else
        ibf = Nothing
        error("Wrong shape. Only 2D and 3D shape with size 3 is supported now.")
    end
    return ibf
end

function _inner_boundary333()
    shape = [3, 3, 3]
    prd = prod(shape)

    face_number = 0
    for i = 1:length(shape)
        # for every axis there is this number of faces
        face_number += (shape[i] + 1) * (prd // shape[i]).num
    end
    filter_arr = spzeros(Int8, face_number)

    filter_arr[14] = 1
    filter_arr[23] = 1
    filter_arr[56] = 1
    filter_arr[53] = 1
    filter_arr[90] = 1
    filter_arr[91] = 1
    return filter_arr
end

function _inner_boundary33()
    shape = [3, 3]
    filter_arr = spzeros(Int8, prod(shape))
    filter_arr[5] = 1
    filter_arr[8] = 1
    filter_arr[18] = 1
    filter_arr[19] = 1
    return filter_arr
end
