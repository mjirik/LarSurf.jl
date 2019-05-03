
# include("../src/lario3d.jl")
# include("arr_fcn.jl")

import SparseArrays.spzeros
import SparseArrays.dropzeros!
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using JLD
using Logging
# using Logger

BoolOrNothing = Union{Bool, Nothing}
_boundary3_storage = Dict()
_param_boundary_allow_memory = true
_param_boundary_allow_read_files = true
_param_boundary_allow_write_files = true

# using arr_fcn

function set_param(;
    boundary_allow_memory::BoolOrNothing=nothing,
    boundary_allow_read_files::BoolOrNothing=nothing,
    boundary_allow_write_files::BoolOrNothing=nothing
    )
    global _param_boundary_allow_read_files
    global _param_boundary_allow_write_files
    global _param_boundary_allow_memory
    if boundary_allow_read_files != nothing
        _param_boundary_allow_read_files = boundary_allow_read_files
    end
    if boundary_allow_write_files != nothing
        _param_boundary_allow_write_files = boundary_allow_write_files
    end
    if boundary_allow_memory != nothing
        _param_boundary_allow_memory = boundary_allow_memory
    end
end

function reset(;
    boundary_storage::BoolOrNothing=nothing,

    )
    if boundary_storage != nothing
        _boundary3_storage = Dict()
    end
end

function _create_name_for_boundary(block_size::Array)
    len = length(block_size)
    if len == 3
        fn = "boundary_matrix_" * string(block_size[1]) * "x" * string(block_size[2]) * "x"  * string(block_size[3]) * ".jld"
    else
         error("Function not defined for this dimension")

        fn = ""
    end

    return fn
end

function get_boundary3(block_size::Array)
    if _param_boundary_allow_memory & haskey(_boundary3_storage, block_size)
        bMatrix = _boundary3_storage[block_size]
        # print(".")
        @debug "."

    else
        fn = _create_name_for_boundary(block_size::Array)
        if _param_boundary_allow_read_files & isfile(fn)
            bMatrix = JLD.load(fn)["boundary_matrix"]
            # print("R")
            @debug "R"
        else
            bMatrix = calculate_boundary3(block_size)
            if _param_boundary_allow_write_files
                JLD.save(fn, "boundary_matrix", bMatrix)
                # print("W")
                @debug "W"
            else
                # print("C")
                @debug "C"
            end
        end
        _boundary3_storage[block_size] = bMatrix
    end
    return bMatrix
#
end


function calculate_boundary3(block_size)
# function get_boundary3(block_size)
    if typeof(block_size) == Tuple{Int64,Int64,Int64}
        block_size = [block_size[1], block_size[2], block_size[3]]
    end
#     V, CVill = Lar.cuboidGrid([block_size[1], block_size[2], block_size[3]])

    # A lot of work can be done by this:
    lmodel::Lar.LARmodel = Lar.cuboidGrid(block_size, true)
    V, (VV, EV, FV, CV) = lmodel
#     model =

    CVchar = Lar.characteristicMatrix(CV)
    FVchar = Lar.characteristicMatrix(FV)
    b3 = CVchar * FVchar'

    b3 = lario3d.sparse_filter!(b3, 4, 1, 0)
    dropzeros!(b3)

#     return b3

#     model
#     println("get_boundary3: 3")
    return b3, lmodel #(V, (VV, EV, FV, CV))
end

# block_size = [2, 2, 2]
# """
# It is wrong beacause the faces are filtered.
# """
# function get_boundary3_wrong(block_size)
#     V, CVill = Lar.cuboidGrid([block_size[1], block_size[2], block_size[3]])
#
#     # A lot of work can be done by this:
#     # V, (VV, EV, FV, CV) = Lar.cuboidGrid([2,2,2], true)
#
#     # CVill to FVi
#     nc = size(CVill)[1]
#     nfaces_per_C = 6
#     nfaces = nfaces_per_C * nc
#     FVi = Array{Int64}(undef, nfaces, 4)
#     #     println(sz)
#     # produce faces
#     for k in 1:nc
#         cube_points = CVill[k]
#         FVi[(k - 1) * nfaces_per_C + 1, :] = cube_points[[1, 2, 4, 3]]
#         FVi[(k - 1) * nfaces_per_C + 2, :] = cube_points[[1, 5, 6, 2]]
#         FVi[(k - 1) * nfaces_per_C + 3, :] = cube_points[[1, 3, 7, 5]]
#         FVi[(k - 1) * nfaces_per_C + 4, :] = cube_points[[3, 4, 8, 7]]
#         FVi[(k - 1) * nfaces_per_C + 5, :] = cube_points[[2, 6, 8, 4]]
#         FVi[(k - 1) * nfaces_per_C + 6, :] = cube_points[[6, 5, 8, 7]]
#     end
#
#     VFi = convert(Array{Int64, 2}, FVi')
#
#
#
#     # convert from list of list to 2D array
#     # CVi = Array{Int64}(undef, size(CVill)[1], size(CVill[1])[1])
#     CVi = ll2array(CVill)
#
#
#     nvertices = size(V)[2]
#
#     # CVill to sparse
#     print("CVill to sparse, sz: ", nc, " nvertices: ", nvertices)
#     VF01 = ind_to_sparse(VFi, nvertices, 1)
#     CV01 = ind_to_sparse(CVi, nvertices, 2)
#
#     boundary_numbers = CV01 * VF01
#
#     # take just o
#
#     boundary = boundary_numbers .== 4
#
#     boundary = convert(Array{Int8, 2}, boundary)
#
#     # list of lists
#
#     FVill = [FVi[k, :] for k=1:size(FVi,1)]
#
#     # Plasm.view(V, CVill)
#     # Plasm.viewexploded(V, CVill)(2,2,2)
#     # Plasm.viewexploded(V, FVill)(2,2,2)
#     print("boundary stats (#true, # false): ", sum(boundary .== true), ", ", sum(boundary .== false) )
#     return boundary, V, FVi
# end
