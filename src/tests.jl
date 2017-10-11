# import sampledata.jl
# test

function test_hexagon()
    """
    # hexaogon
    #
    #    3 -- 4
    #  /  \ /  \
    # 1 -- 2 -- 5
    #  \  / \  /
    #   7 -- 8
    """
    hexagon_vertices, hexagon_faces = hexagon()
    FEinds, EVinds = get_FEinds_and_EVinds(hexagon_faces)
    assert(size(FEinds,1) == 6)
    assert(size(FEinds,2) == 3)
    assert(size(EVinds,1) == 12)
    assert(size(EVinds,2) == 2)
end
# full(EVinds)
