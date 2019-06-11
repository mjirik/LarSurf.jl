using Distributed
_single_boundary3 = nothing
_b3_size = nothing
_ch_block = RemoteChannel(()->Channel{Tuple{Array{Int8,3},Array{Int64,1},Array{Int64,1},Int64}}(32));

function set_single_boundary3(b3)
    global _single_boundary3
    _single_boundary3 = b3
    println("set boundary ")
end

"""
Lar Surf Parallel setup.
"""
function lsp_setup(block_size)
    global _b3_size
    println("block_size: $block_size")
    block_size = LarSurf.size_as_array(block_size)
    println("block_size: $block_size")
    b3, larmodel = LarSurf.get_boundary3(block_size)
    println("block_size: $block_size")
    _b3_size = block_size
    println("b3 calculated")
    # ftch = Array(Int64, nworkers())
    @sync for wid in workers()
        println("worker id: $wid")
        # ftch[wid] =
        @spawnat wid LarSurf.set_single_boundary3(b3)
    end
end

function lsp_job_enquing(segmentation)
    global _ch_block
    # global _b3_size
    println("b3_size type $(typeof(_b3_size))")
    n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)

    for i=1:n
        block = LarSurf.get_block(i, bgetter...)
        put!(_ch_block, (block...,i))
    end
end

function lsp_do_work_code_multiply_decode(data_size, ch_block, ch_faces)
    println("working on code mul decode")
    fbl = take!(ch_block)
    println("type of : $(typeof(ch_block))")
    faces = LarSurf.code_multiply_decode(data_size, fbl...)
    return faces
end


function three_chain_coding(segmentation)
    return grid_to_linear(segmentation, 0)
end


"""
Decode 2-chain (Flin) to global IDs.
"""
function two_chain_decoding(Flin, data_size, offset, block_size, fid)
    # TODO block_size and offset are in different order in two functions
    # sub_bgrid_fac..face_id() and  get_block()
# face from small to big
    i, j, v = findnz(Flin)
    return [
        sub_grid_face_id_to_orig_grid_face_id(
        data_size, block_size, offset, fid
        )[1]
        for fid in j
    ]
end


"""
Calculate multiplication linearized volume cells with boundary matrix and
filter it for number 1.
"""
# function grid_get_surf_Fvec_larmodel(segmentation::AbstractArray)
function code_multiply_decode(
    data_size::Array,
    segmentation::Array, offset, block_size, fid
    )
    @debug "code multiply decode"
    println("code multiply decode")

    println("data_size: $data_size, seg_size: $(size(segmentation))")
    println("block_size: $block_size, offset: $offset, fid: $fid")
    segClin = three_chain_coding(segmentation)
    b3 = _single_boundary3

    # Multiplication step
    Flin = segClin' * b3

    ## Filtration
    sparse_filter!(Flin, 1, 1, 0)
    dropzeros!(Flin)


    Flist = two_chain_decoding(Flin,
        data_size, offset, block_size, fid
    )
    return Flist
end
