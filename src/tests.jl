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




function test_remove_double_vertex()
    test_vertex = [ 1 2; 2 3; 4 1; 2 3; 3 3]
    test_faces = [
        1 3 4;
        4 5 1;
        1 5 4
    ]

    Vs, Is = remove_double_vertexes_alternative(test_vertex)

    for i in 1:size(test_vertex, 1)
        v1 = Vs[Is[i]]
        v2 = test_vertex[i,:]
        assert(v1 == v2)
    end
end

