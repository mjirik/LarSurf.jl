using Distributed
_single_boundary3 = Nothing

function set_single_boundary3(b3)
    global _single_boundary3
    _single_boundary3 = b3
end

function surf_init(block_size)
    b3, larmodel = LarSurf.get_boundary3(block_size)
    @spawn set_single_boundary3(b3)
    # @everywhere LarSurf.set_single_boundary3(b3)
end
