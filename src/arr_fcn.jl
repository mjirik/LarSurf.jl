import SparseArrays.spzeros
import SparseArrays.rowvals
import SparseArrays.nzrange
import SparseArrays.nonzeros

function array_compare(arr1, arr2)
end

"""
Filter sparse matrix. Set new values in matrix.
"""
function sparse_filter!(sparse, what_to_find, true_value, false_value)
    A = sparse
    rows = rowvals(A)
    vals = nonzeros(A)
    m, n = size(A)
    for i = 1:n
       for j in nzrange(A, i)
          row = rows[j]
          val = vals[j]
          if val == what_to_find
              newval = true_value
          else
              newval = false_value
          end
          vals[j] = newval
       end
    end
    return A
end


"""
Expand indexes into sparse horizontally.
Convert CV with vertex indexes (Int64) to sparse CV with just zeros and ones.

It should be the same as lar.CharacteristicMatrix()
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

"""
Create VV matrix representing identity matrix in list of lists format with indices.

julia> createVVll(5)

[[1], [2], [3], [4], [5]]
"""
function createVVll(number_of_vertices)

    VVm32 = [[i] for i=1:size_of_vertices]
    return VVm32
end


"""
Convert size in tuple to size in array
"""
function size_as_array(block_size)
    if typeof(block_size) == Tuple{Int64,Int64,Int64}
        block_size = [block_size[1], block_size[2], block_size[3]]
    end
    return block_size
end

function hard_max!(stop, data_size)
    for i=1:length(stop)
        if data_size[i] < stop[i]
            stop[i] = data_size[i]
        end
    end
    return stop
end
