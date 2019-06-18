using Distributed
_single_boundary3 = nothing
_b3_size = nothing
_ch_block = RemoteChannel(()->Channel{Tuple{Array{Int8,3},Array{Int64,1},Array{Int64,1},Int64}}(32));
_ch_results = RemoteChannel(()->Channel{Array}(32));
_data_size = nothing
_workers_running = false
# _setup_counter = 0

function set_single_boundary3(b3, block_size)
    global _single_boundary3, _b3_size
    _single_boundary3 = b3
    _b3_size = block_size
    # println("set boundary ")
end

function set_data_size(data_size)
    @debug "Set data size"
    global _data_size
    _data_size = data_size
end

function set_channels(ch_block, ch_results)
    global _ch_block, _ch_results
    _ch_block = ch_block
    _ch_results = ch_results
end

"""
Lar Surf Parallel setup.
"""
function lsp_setup(block_size)
    global _b3_size, _workers_running
    # global _ch_block, _ch_results
    @info "lsp setup with block_size: $block_size"
    block_size = LarSurf.size_as_array(block_size)
    # println("block_size: $block_size")
    b3, larmodel = LarSurf.get_boundary3(block_size)
    # println("block_size: $block_size")
    _b3_size = block_size
    @debug "b3 calculated, _b3_size: $_b3_size"
    @sync for wid in workers()
        @info "starting worker id: $wid"
        # ftch[wid] =
        @spawnat wid LarSurf.set_single_boundary3(b3, block_size)
        @spawnat wid LarSurf.set_channels(_ch_block, _ch_results)
    end
    if _workers_running
        @debug "Workers are alredy initiated. No need to do it again."
    else
        for wid in workers()
                @debug "Initiating workers"
                remote_do(
                    LarSurf.lsp_do_work_code_multiply_decode,
                    wid,
                    LarSurf._ch_block,
                    LarSurf._ch_results,
                )
        end
        _workers_running = true
    end

end

function lsp_deinit_workers(ch_block::RemoteChannel, ch_faces::RemoteChannel)
    global _workers_running
    if _workers_running
        @debug "Sending 'nothing'"
        for wid in workers()
            put!(_ch_block, nothing)
        end
        _workers_running = false
    else
        @warn "No workers to deinit"
    end
end

function lsp_get_surface(segmentation)

    n, bgetter, data_size = LarSurf.lsp_setup_data(segmentation)
    @async LarSurf.lsp_job_enquing(n, bgetter)

    # Workers are started before in setup


    # print("===== Output Faces =====")
    @info "============== end (sequential) ========"
    tm_end = @elapsed begin
        numF = LarSurf.grid_number_of_faces(data_size)
        bigFchar = spzeros(Int8, numF)
        for i=1:n
            @debug "Collecting the information for block $i"
            faces_per_block = take!(_ch_results)
            # println(faces_per_block)
            # for  block_i=1:block_number
                for big_fid in faces_per_block
                    # median time 31 ns
                    # bigFchar[big_fid] = (bigFchar[big_fid] + 1) % 2
                    # median time 14 ns
                    bigFchar[big_fid] = if (bigFchar[big_fid] == 1) 0 else 1 end
                end
            # end

        end
        bigV, FVreduced = grid_Fchar_to_Vreduced_FVreduced(bigFchar, data_size)
    end
    @info "End (sequential) time: $tm_end"
    return bigV, FVreduced
    # return __make_return(V, filteredFV, Flin, larmodel, return_all)
    # return bigFchar
end



function lsp_setup_data(segmentation)
    # global _b3_size
    # println("b3_size type $(typeof(_b3_size))")
    data_size = LarSurf.size_as_array(size(segmentation))
    n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)
    @sync for wid in workers()
        @info "set data size on worker: $wid"
        # ftch[wid] =
        @spawnat wid LarSurf.set_data_size(data_size)
    end
    return n, bgetter, data_size

end

function lsp_job_enquing(n, bgetter)
    global _ch_block
    # global _b3_size
    # println("b3_size type $(typeof(_b3_size))")
    # n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)

    for block_id=1:n
        tm_get_block = @elapsed block = LarSurf.get_block(block_id, bgetter...)

        tm_put = @elapsed put!(_ch_block, (block..., block_id))
        # @info "== Job enquing get_block time: $tm_get_block, put time: $tm_put"
        # , channel size: $(lenght(_ch_block))"
    end
    @info "Job enquing finished"
end

function lsp_do_work_code_multiply_decode(ch_block, ch_faces)
    # global _data_size
    while true
        @debug "waiting for data on worker $(myid())"
        fbl = take!(ch_block)
        # println("type of : $(typeof(ch_block))")
        if fbl == nothing
            @debug "recived 'nothing' quit worker $(myid())"
            # put!(ch_block, nothing)
            return
        end
        @info "working on block $(fbl[end]), code mul decode on worker $(myid())"
        data_size = _data_size
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
