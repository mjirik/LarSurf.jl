using Distributed
_single_boundary3 = Nothing

function set_single_boundary3(b3)
    global _single_boundary3
    _single_boundary3 = b3
    println("set boundary ")
end

function surf_init(block_size)
    b3, larmodel = LarSurf.get_boundary3(block_size)
    println("b3 calculated")
    # ftch = Array(Int64, nworkers())
    @sync for wid in workers()
        println("worker id: $wid")
        # ftch[wid] =
        @spawnat wid LarSurf.set_single_boundary3(b3)
    end


    # println("spawn future", spawn_future)

    # fetch(spawn_future)
    # @everywhere LarSurf.set_single_boundary3(b3)
end
