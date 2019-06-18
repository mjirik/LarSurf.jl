
# include("../src/jl")
# include("arr_fcn.jl")

import SparseArrays.spzeros
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation

using Distributed
import SparseArrays.dropzeros!
# using JLD
using JLD2, FileIO
using Logging
BoolOrNothing = Union{Bool, Nothing}

# @everywhere import SparseArrays.dropzeros!
# @everywhere using JLD
# @everywhere using Logging
# @everywhere using Distributed
# @everywhere BoolOrNothing = Union{Bool, Nothing}

# @everywhere _boundary3_storage = Dict()
_boundary3_storage = Dict();
_larmodel_storage = Dict();
# _global_boundary3_storage = @spawn _boundary3_storage;
_param_boundary_allow_memory = true
_param_boundary_allow_read_files = false
_param_boundary_allow_write_files = false
_param_larmodel_allow_memory = true
_param_larmodel_allow_read_files = false
_param_larmodel_allow_write_files = false

# using arr_fcn

function set_param(;
    boundary_allow_memory::BoolOrNothing=nothing,
    boundary_allow_read_files::BoolOrNothing=nothing,
    boundary_allow_write_files::BoolOrNothing=nothing,
    larmodel_allow_memory::BoolOrNothing=nothing,
    larmodel_allow_read_files::BoolOrNothing=nothing,
    larmodel_allow_write_files::BoolOrNothing=nothing
    )
    global _param_boundary_allow_read_files
    global _param_boundary_allow_write_files
    global _param_boundary_allow_memory
    global _param_larmodel_allow_read_files
    global _param_larmodel_allow_write_files
    global _param_larmodel_allow_memory
    if boundary_allow_read_files != nothing
        _param_boundary_allow_read_files = boundary_allow_read_files
    end
    if boundary_allow_write_files != nothing
        _param_boundary_allow_write_files = boundary_allow_write_files
    end
    if boundary_allow_memory != nothing
        _param_boundary_allow_memory = boundary_allow_memory
    end
    if larmodel_allow_read_files != nothing
        _param_larmodel_allow_read_files = larmodel_allow_read_files
    end
    if larmodel_allow_write_files != nothing
        _param_boundary_allow_write_files = larmodel_allow_write_files
    end
    if larmodel_allow_memory != nothing
        _param_larmodel_allow_memory = larmodel_allow_memory
    end
end

function reset(;
    boundary_storage::BoolOrNothing=nothing,

    )
    if boundary_storage != nothing
        # _boundary3_storage = @spawn Dict()
        _boundary3_storage = Dict()
    end
end

function _create_name_for_boundary(block_size::Array, prefix::String="boundary_matrix_")
    len = length(block_size)
    if len == 3
        fn = prefix * string(block_size[1]) * "x" * string(block_size[2]) * "x"  * string(block_size[3]) * ".jld2"
    else
         error("Function not defined for this dimension")

        fn = ""
    end
    return fn
end

function get_larmodel(block_size::Array)
    if _param_larmodel_allow_memory & haskey(_larmodel_storage, block_size)
        larmodel = _larmodel_storage[block_size]
    else
        fn = _create_name_for_boundary(block_size::Array, "larmodel_")

        # fn = _create_name_for_boundary(block_size::Array)
        if _param_larmodel_allow_read_files & isfile(fn)
            # larmodel = JLD.load(fn)["larmodel"]
            larmodel = FileIO.load(fn, "larmodel")
            # print("R")
            # @debug "R"
        else
            # println("==== caluculate larmodel")
            larmodel::Lar.LARmodel = Lar.cuboidGrid(block_size, true)
            __fix_cuboidGrid_FV!(larmodel)
            # println("==== boundary calculated")
            if _param_larmodel_allow_write_files
                # JLD.save(fn, "larmodel", larmodel)
                FileIO.save(fn, "larmodel", larmodel)
                # print("W")
                # @debug "W"
            else
                # print("C")
                @debug "C"
            end
        end
        _larmodel_storage[block_size] = larmodel
    end
    return larmodel
end

function get_boundary3(block_size::Array, return_larmodel=true)

    # println("== get_boundary3 function called ", typeof(_boundary3_storage), " ", keys(_boundary3_storage))
    global _global_boundary3_storage
    # _boundary3_storage = fetch(_global_boundary3_storage)
    # println("== fetch finished")
    if _param_boundary_allow_memory & haskey(_boundary3_storage, block_size)
        bMatrix = _boundary3_storage[block_size]
        # println("==== boundary from memory")
        @debug "."
        if return_larmodel
            larmodel = get_larmodel(block_size)
        end

    else
        fn = _create_name_for_boundary(block_size::Array)
        if _param_boundary_allow_read_files & isfile(fn)
            # bMatrix = JLD.load(fn)["boundary_matrix"]
            bMatrix = FileIO.load(fn, "boundary_matrix")
            # print("R")
            @debug "R"
            if return_larmodel
                larmodel = get_larmodel(block_size)
            end
        else
            println("==== caluculate boundary")
            bMatrix, larmodel = calculate_boundary3(block_size)
            # println("==== boundary calculated")
            if _param_boundary_allow_write_files
                # JLD.save(fn, "boundary_matrix", bMatrix)
                FileIO.save(fn, "boundary_matrix", bMatrix)
                # print("W")
                @debug "W"
            else
                # print("C")
                @debug "C"
            end
        end
        _boundary3_storage[block_size] = bMatrix
        # _boundary3_storage = @spawn local_boundary3_storage;
    end
    # println("== get_boundary3 function end")
    if return_larmodel
        return bMatrix, larmodel
    else
        return bMatrix
    end
#
end

# @everywhere begin
    """
    In cuboidGrid the order for node id in faces is wrong.
    Here is the fix by swapping last two array elements.
    """
    function __fix_cuboidGrid_FV!(larmodel::Lar.LARmodel)
        FV = larmodel[2][3]
        for oneF in FV
            tmp = oneF[4]
            oneF[4] = oneF[3]
            oneF[3] = tmp
        end
    end


    function calculate_boundary3(block_size)
    # function get_boundary3(block_size)
        if typeof(block_size) == Tuple{Int64,Int64,Int64}
            block_size = [block_size[1], block_size[2], block_size[3]]
        end
    #     V, CVill = Lar.cuboidGrid([block_size[1], block_size[2], block_size[3]])

        # A lot of work can be done by this:
        lmodel = get_larmodel(block_size)
        # lmodel::Lar.LARmodel = Lar.cuboidGrid(block_size, true)
        V, (VV, EV, FV, CV) = lmodel
    #     model =
        # __fix_cuboidGrid_FV!(lmodel)

        CVchar = Lar.characteristicMatrix(CV)
        FVchar = Lar.characteristicMatrix(FV)
        b3 = CVchar * FVchar'

        # b3 = sparse_filter!(b3, 4, 1, 0)
        b3 = sparse_filter!(b3, 4, 1, 0)
        dropzeros!(b3)

    #     return b3

    #     model
    #     println("get_boundary3: 3")
        return b3, lmodel #(V, (VV, EV, FV, CV))
    end
# end
