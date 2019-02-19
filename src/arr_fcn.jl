function array_compare(arr1, arr2)
end

"""
Expand indexes into sparse horizontally.
Convert CV with vertex indexes (Int64) to sparse CV with just zeros and ones.

"""
function _CVi_to_CV01(CVi, nvertices)
    nc = size(CVi)[1]
    nvertices_per_C = size(CVi)[2]
    CV01 = spzeros(Int8, nc, nvertices)

    for k in 1:nc
        for i in 1:nvertices_per_C
            # print("vert k: ", k,", i: ", i)
            vertind = CVi[k, i]
            # print(" vert ind: ", vertind, "\n")
            CV01[k, vertind] = 1
        end
    end
    return CV01
end

# CV01 = CVi_to_CV01(CVi, nvertices)

# VF to sparse
# print("VF to sparse")


function _VFi_to_VF01(VFi, nvertices)
    nfaces = size(VFi)[2]
    VF01 = spzeros(Int8, nvertices, nfaces)

    for k in 1:size(VFi)[1]
        for i in 1:(size(VFi)[2])
            # print("vert k: ", k,", i: ", i)
            vertind = VFi[k, i]
            # print(" vert ind: ", vertind, "\n")
            VF01[vertind, i] = 1
        end
    end
    return VF01
end
# ind_to_sparse_v = VFi_to_VF01

# VF01 = ind_to_sparse_v(VFi, nvertices)
"""
Based on matrix with indexes expand the index into sparse array containing one
and zero.
"""
function ind_to_sparse(CVi, nvertices, axis)
    if axis == 1
        CV01 = _VFi_to_VF01(CVi, nvertices)
    elseif axis == 2
        CV01 = _CVi_to_CV01(CVi, nvertices)
    else
        error("Axis should be 1 or 2")
    end
    return CV01
end


"""
Input is list of lists
Output is 2D Array
"""
function ll2array(CVill)
    nc = size(CVill)[1]
    CVi = Array{typeof(CVill[1][1])}(undef, size(CVill)[1], size(CVill[1])[1])
    for k in 1:nc
        CVi[k, :] = CVill[k]
    end
    return CVi
end
