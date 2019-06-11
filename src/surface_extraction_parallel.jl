using Distributed
_single_boundary3 = nothing
_b3_size = nothing

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
    # global _b3_size
    println("b3_size type $(typeof(_b3_size))")
    n, bgetter = LarSurf.block_getter(segmentation, _b3_size, fixed_block_size=true)

    for i=1:n
        block = LarSurf.get_block(i, bgetter...)
    end
end
