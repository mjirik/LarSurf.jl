# Paper notes
# Channel is emptyed with every setup to prevent unexpected behavior.

using Distributed

using Dates

# const BlockAndMetaOrNothing = Union{Tuple{Array{Int8,3},Array{Int64,1},Array{Int64,1},Int64}, Nothing}
const BlockAndMetaOrNothing = Union{Int64, Nothing}
const ArrayOrNothing = Union{Array, Nothing}
_single_boundary3 = nothing
# _b3_size = nothing # it is set in boundary_operator.jl
# _ch_block::RemoteChannel = nothing
# _ch_results::RemoteChannel = nothing
# _ch_block = nothing
# _ch_results = nothing
_ch_block = RemoteChannel(()->Channel{BlockAndMetaOrNothing}(32));
_ch_results = RemoteChannel(()->Channel{ArrayOrNothing}(32));
_data_size = nothing
_workers_running = false
_reference_time = nothing
# time data cane be used for measurement
# set it with _set_time_data()
# init on all workers is done in lsp_setup()
# data are computed in lsp_do_work_code_multiply_decode()
_time_data = nothing
_time_data_i = 1
_segmentation_data = nothing
_bgetter = nothing



# const _local_time_data = Dict()
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

function set_time_data(tm_data=nothing)
    global _time_data, _time_data_i
    if tm_data == nothing
        tm_data = Dict()
    end
    _time_data = tm_data
    if _time_data != nothing
        # _time_data["total take time $(myid())"] = 0.
        # _time_data["total computation time $(myid())"] = 0.
        # _time_data["total put time $(myid())"] = 0.
        _time_data["cumulative take time $(myid())"] = 0.
        _time_data["cumulative computation time $(myid())"] = 0.
        _time_data["cumulative put time $(myid())"] = 0.
        _time_data["number of processed blocks $(myid())"] = 0
        _time_data_i = 1
    end
end

function _get_local_time_data()
    return _time_data
end

function get_time_data()
    global _time_data
    if _time_data != nothing
        # @info "_time_data before" _time_data
        for wid in workers()
            tmd = @spawnat wid LarSurf._get_local_time_data()
            tmdf = fetch(tmd)
            # @info "fetch tmd" tmdf
            merge!(_time_data, tmdf)

        end
        # @info "_time_data after" _time_data
    end
    return _time_data
end

"""
Lar Surf Parallel setup.
The reference time can be passed in to measure time.
"""
function lsp_setup(block_size; reference_time=nothing)
    global _workers_running, _reference_time
    global _ch_block, _ch_results
    global _b3_size
    global _single_boundary3
    if reference_time == nothing
        _reference_time = time()
    else
        _reference_time = reference_time
    end
    if nprocs() == 1
        addprocs(1)
        @info "Adding one worker"
    end
    # @everywhere using LarSurf
    # global _ch_block, _ch_results
    @info "lsp setup with block_size: $block_size"
    block_size = LarSurf.size_as_array(block_size)
    # println("block_size: $block_size")
    # Causes error = non existing SparseMatrixCSC
    LarSurf.set_param(boundary_allow_read_files=true, boundary_allow_write_files=true)
    # LarSurf.set_param(boundary_allow_read_files=false, boundary_allow_write_files=false)
    # tm = @elapsed b3, larmodel = LarSurf.get_boundary3(block_size, false)
    tm = @elapsed b3 = LarSurf.get_boundary3(block_size, false)
    @info "time for construction of b3 " tm
    # println("block_size: $block_size")
    # set on local
    # set_single_boundary3(b3, block_size)
    _b3_size = block_size
    _single_boundary3 = b3
    @debug "b3 calculated, _b3_size: $_b3_size"
    tim0 = time()
    @sync for wid in workers()
        @info "starting worker id: $wid"
        # ftch[wid] =
        @spawnat wid LarSurf.set_single_boundary3(b3, block_size)

        # @TODO this can be in next for and without sync
    end
    @info "time used for starting workers$(time() - tim0)"
    if _workers_running
        empty_channel(_ch_block)
        empty_channel(_ch_results)
        @debug "Workers are alredy initiated. No need to do it again."
    else
        for wid in workers()
                @debug "Initiating workers"
                @info "remote do for worker $(myid())"
                remote_do(
                    LarSurf.lsp_do_work_code_multiply_decode,
                    wid,
                    _ch_block,
                    _ch_results,
                    # LarSurf._ch_block,
                    # LarSurf._ch_results,
                )
        end
        _workers_running = true
    end
    @info "setup done in $(time() - _reference_time)"



end

# function lsp_deinit_workers(ch_block::RemoteChannel=nothing, ch_faces::RemoteChannel=nothing)

function lsp_deinit_workers()
    global _workers_running, _ch_block
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

"""
Extract surface after lsp_setup().

If set_time_data is set to Dict, the time measurements will be stored there.
"""
function lsp_get_surface(segmentation; voxelsize=[1,1,1])

    n, bgetter, data_size = LarSurf.lsp_setup_data(segmentation)
    for wid in workers()
        if _time_data != nothing
            @spawnat wid LarSurf.set_time_data(_time_data)
        end
    end


    @async LarSurf.lsp_job_enquing(n, bgetter)

    # Workers are started before in setup


    # print("===== Output Faces =====")
    @info "============== Sequential finished ======== in time $(time()-_reference_time) [s]"
    # cumulative_decoding_time = 0
    cumulative_doubled_filtration_time = 0
    tm_end = @elapsed begin
        numF = LarSurf.grid_number_of_faces(data_size)
        bigFchar = spzeros(Int8, numF)
        for i=1:n

            @debug "Collecting the information for block $i (first three messages)" maxlog=3
            faces_per_block = take!(_ch_results)
            if i == 1
                @info "First faces recived in time: $(time()-_reference_time) [s]"
                if _time_data != nothing
                    _time_data["first face recived"] = time()-_reference_time
                end
            end
            # println(faces_per_block)
            # for  block_i=1:block_number
            tm_doubled_filtration = @elapsed for big_fid in faces_per_block
                # median time 31 ns
                # bigFchar[big_fid] = (bigFchar[big_fid] + 1) % 2
                # median time 14 ns
                bigFchar[big_fid] = if (bigFchar[big_fid] == 1) 0 else 1 end
            end
            cumulative_doubled_filtration_time = cumulative_doubled_filtration_time + tm_doubled_filtration
            # println(bigFchar)
            # end

        end
        @info "=== Parallel processing finished === Last faces recived in time: $(time()-_reference_time) [s]"
        # @info "Last faces recived in time: $(time()-_reference_time) [s] === end sequential ==="
        if _time_data != nothing
            _time_data["last face recived"] = time()-_reference_time
        end
        dropzeros!(bigFchar)
        # bigV, FVreduced = grid_Fchar_to_Vreduced_FVreduced(bigFchar, data_size; voxelsize=voxelsize)
        reduction_time = @elapsed bigV, FVreduced = grid_Fchar_to_Vreduced_FVreduced(bigFchar, data_size; voxelsize=voxelsize)
        # cumulative_decoding_time = cumulative_decoding_time + dec_time
    end
    @info "reciving and decoding time [s]: $tm_end"
    if _time_data != nothing
        _time_data["reciving and decoding time [s]"] = tm_end
        _time_data["V and FV reduction time [s]"] = reduction_time
        _time_data["cumulative double face filtration time [s]"] = cumulative_doubled_filtration_time
    end
    return bigV, FVreduced
    # return __make_return(V, filteredFV, Flin, larmodel, return_all)
    # return bigFchar
end

function set_data_local(data)
    global _segmentation_data = data
end

function set_bgetter(bgetter)
    global _bgetter = bgetter
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
        @spawnat wid LarSurf.set_bgetter(bgetter)
    end
    return n, bgetter, data_size

end

function lsp_job_enquing(n, bgetter)
    global _ch_block
    # global _b3_size
    # println("b3_size type $(typeof(_b3_size))")
    # n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)

    for block_id=1:n
        # @info "getting block $block_id"
        # tm_get_block = @elapsed block = LarSurf.get_block(block_id, bgetter...)
        # @info "putting block $block_id to channel"

        tm_put = @elapsed put!(_ch_block, block_id)
        # tm_put = @elapsed put!(_ch_block, (block..., block_id))
        if block_id == 1
            @info "First block sent in channel in time: $(time()-_reference_time) [s]"
            if _time_data != nothing
               _time_data["first block sent"] = time()-_reference_time
            end
        end

        # @info "== Job enquing get_block time: $tm_get_block, put time: $tm_put"
        # , channel size: $(lenght(_ch_block))"
    end
    @info "Last block sent in channel in time: $(time()-_reference_time) [s]"
    @info "Job enquing finished"
end

function lsp_do_work_code_multiply_decode(ch_block, ch_faces)
    @info "do work while initiated on worker $(myid())"
    global _data_size, _time_data_i
    # ref_time = 0.
    # after_take_time = 0
    # _local_time_data["first waiting time"] = 0.
    # _time_data[]
    while true
        @info "waiting for data on worker $(myid())" maxlog=2
        ref_time = time()

        fbl = take!(ch_block)
        after_take_time = time()
        # println("type of : $(typeof(ch_block))")
        if fbl == nothing
            @info "recived 'nothing' quit worker $(myid())"
            # put!(ch_block, nothing)
            return
        end
        # @info "code mul decode on block $(fbl[end]), worker $(myid()), " maxlog=3

         # $(time()-_reference_time)(first 3 messages per worker)" maxlog=3
        block_id = fbl
        data_size = _data_size
        block = LarSurf.get_block(block_id, _bgetter...)
        faces = LarSurf.code_multiply_decode(data_size, block..., block_id)
        # faces = LarSurf.code_multiply_decode(data_size, fbl...)
        after_work_time = time()
        put!(ch_faces, faces)
        after_put_time = time()
        # time measurement
        ttake = after_take_time - ref_time
        twork = after_work_time - after_take_time
        tput = after_put_time - after_work_time
        if _time_data != nothing
            _time_data["cumulative take time $(myid())"] += ttake
            _time_data["cumulative computation time $(myid())"] += twork
            _time_data["cumulative put time $(myid())"] += tput
            _time_data["number of processed blocks $(myid())"] += 1
            if _time_data_i == 1
                _time_data["first take time $(myid())"] = ttake
            end
            _time_data_i = 2
        end
        @debug "code mul decode on block $(fbl[end]), worker $(myid()), $ttake, $twork, $tput"
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


function empty_channel(ch::RemoteChannel)
    while isready(ch)
        take!(ch)
        @warn "Something was in channel. Now it is empty." maxlog=1
    end
end
