using Distributed
_single_boundary3 = nothing
_b3_size = nothing
_ch_block = RemoteChannel(()->Channel{Tuple{Array{Int8,3},Array{Int64,1},Array{Int64,1},Int64}}(32));

function set_single_boundary3(b3, block_size)
    global _single_boundary3, _b3_size
    _single_boundary3 = b3
    _b3_size = block_size
    # println("set boundary ")
end

"""
Lar Surf Parallel setup.
"""
function lsp_setup(block_size)
    global _b3_size
    # println("block_size: $block_size")
    block_size = LarSurf.size_as_array(block_size)
    # println("block_size: $block_size")
    b3, larmodel = LarSurf.get_boundary3(block_size)
    # println("block_size: $block_size")
    _b3_size = block_size
    @debug "b3 calculated, _b3_size: $_b3_size"
    # ftch = Array(Int64, nworkers())
    @sync for wid in workers()
        @info "starting worker id: $wid"
        # ftch[wid] =
        @spawnat wid LarSurf.set_single_boundary3(b3, block_size)
    end

end

function lsp_setup_data(segmentation)
    # global _b3_size
    # println("b3_size type $(typeof(_b3_size))")
    n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)
    return n, bgetter

end

function lsp_job_enquing(n, bgetter)
    global _ch_block
    # global _b3_size
    # println("b3_size type $(typeof(_b3_size))")
    # n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)

    for block_id=1:n
        block = LarSurf.get_block(block_id, bgetter...)
        put!(_ch_block, (block..., block_id))
    end
    @debug "Sending 'nothing'"
    put!(_ch_block, nothing)
end

function lsp_do_work_code_multiply_decode(data_size, ch_block, ch_faces)
    # global
    while true
        @info "working on code mul decode on $(myid())"
        fbl = take!(ch_block)
        # println("type of : $(typeof(ch_block))")
        if fbl == nothing
            @debug "recived 'nothing'"
            put!(ch_block, nothing)
            return
        end
        faces = LarSurf.code_multiply_decode(data_size, fbl...)
        put!(ch_faces, faces)
    end
end


function three_chain_coding(segmentation)
    return grid_to_linear(segmentation, 0)
end


"""
Decode 2-chain (Flin) to global IDs.
"""
function two_chain_decoding(Flin, data_size, offset, block_size, block_id)
    # TODO block_size and offset are in different order in two functions
    # sub_bgrid_fac..face_id() and  get_block()
# face from small to big

    # println("block_id: $block_id, data_size: $data_size, block_size: $block_size, offset: $offset")
    i, j, v = findnz(Flin)
    # fid_small = [
    #     fid
    #     for fid in j
    # ]
    ret = [
        sub_grid_face_id_to_orig_grid_face_id(
        data_size, block_size, offset, fid
        )[1]
        for fid in j
    ]
    # println("decode")
    # println(fid_small)
    # println(ret)
    return ret
end


"""
Calculate multiplication linearized volume cells with boundary matrix and
filter it for number 1.
"""
# function grid_get_surf_Fvec_larmodel(segmentation::AbstractArray)
function code_multiply_decode(
    data_size::Array,
    segmentation::Array, offset, block_size, block_id
    )
    # @debug "code multiply decode"
    # println("code multiply decode")

    # println("data_size: $data_size, seg_size: $(size(segmentation)) \n",
    # "block_size: $block_size, offset: $offset, block_id: $block_id\n",
    # # "segmentation: \n$segmentation"
    # "segmentation\n $(segmentation[1, :, :]), $(segmentation[2,:,:])",
    # )
    segClin = three_chain_coding(segmentation)
    # println("segClin: $segClin")
    b3 = _single_boundary3

    # Multiplication step
    Flin = segClin' * b3
    # println("Flin: $Flin")

    ## Filtration
    sparse_filter!(Flin, 1, 1, 0)
    dropzeros!(Flin)
    # println("Flin filtered: $Flin")
    # println("_b3_size: $(typeof(_b3_size))")
    # _b3_size

    Flist = two_chain_decoding(Flin,
        # data_size, offset, block_size, block_id
        data_size, offset, _b3_size, block_id
    )
    return Flist
end
