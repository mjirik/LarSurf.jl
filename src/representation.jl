# Check functions

function check_vf(vertices, faces, display=false)
    """
    Analyse limits of vertexes and faces
    """

    mn = minimum(faces)
    mx = maximum(faces)
    vn = size(vertices, 1)
    if mn < 1
        println("vertex index lower than 1")
        println("faces min $(mn), faces max $(mx), vertex number $(vn)")
    end
    if mx < vn
        println("vertex index index higher than voxel number")
        println("faces min $(mn), faces max $(mx), vertex number $(vn)")
    end
    if display
        println("faces min $(mn), faces max $(mx), vertex number $(vn)")
    end
end

function check_vevfe(vertices, ev, fe)
    """
    Check LAR representation.
    """

    vnv = size(vertices, 1)
    fnfe = size(fe, 1)
    enfe = size(fe, 2)
    enev = size(ev, 1)
    vnev = size(ev, 2)


    if enfe != enev
        println("Different number of edges in EV and FE")
    end
    if vnv != vnev
        println("Different number of vertices in EV and V")
    end

    if -1 != minimum(fe)
        println("Minimum value of FE should be -1 and it is $(minimum(fe))")
    end
    if 1 != maximum(fe)
        println("Maximum value of FE should be 1 and it is $(maximum(fe))")
    end
    if -1 != minimum(ev)
        println("Minimum value of EV should be -1 and it is $(minimum(fe))")
    end
    if 1 != maximum(ev)
        println("Maximum value of EV should be 1 and it is $(maximum(fe))")
    end


    if eltype(fe) != Int8
        println("Element type of FE should be Int8 and it is $(eltype(fe))")
    end

    if eltype(ev) != Int8
        println("Element type of EV should be Int8 and it is $(eltype(ev))")
    end

end




#
#  convert data from obj to LAR

function iter_edge(edge, EVinv, iedges)
    """
    Add edge to EVinds_dict if it is not there end return edge_id.
    """
    # edge1
    edge_tuple = tuple(edge[:]...)
    if haskey(EVinv, edge_tuple)
        edge_id = EVinv[edge_tuple]
    else
        iedges = iedges + 1
        EVinv[edge_tuple] = iedges
        edge_id = iedges
    end
    edge1id = edge_id

    return edge_id, edge_tuple, iedges
end

function EVinv_to_EVinds(EVinv, nedges)
    """
    EVinv: inverse edge to vertes. Dictionary where key is tuple with vertex index and value is edge id.
    """
    EVinds = Array(Int64, nedges, 2)
    for pair in EVinv
        edge, edgeid = pair
        EVinds[edgeid, 1] = edge[1]
        EVinds[edgeid, 2] = edge[2]
    end
    return EVinds
end

function get_FEinds_and_EVinv(faces, nfaces=nothing)
    """
    :faces: Array nfaces x 3

    Return
    FEinds: face to edge array. Contain indexes of edges
    EVinv: inverse edge to vertes. Dictionary where key is tuple with vertex index and value is edge id.
    """
# Create list of unique edges and create FEinds
# Keep order of vertex in faces. It is important for face orientation.
    if nfaces == nothing
        nfaces = size(faces, 1)
    end
    Einds = []
    EVinv = Dict()
    FEinds = Array(Int64, nfaces, 3)
    iedges = 0
    for i = 1:nfaces
        face = sort(faces[i,:])

        # edge1
        edge = [face[1], face[2]]
        edge1_id, edge_tuple, iedges = iter_edge(edge, EVinv, iedges)

        edge = [face[2], face[3]]
        edge2_id, edge_tuple, iedges = iter_edge(edge, EVinv, iedges)

        edge = [face[1], face[3]]
        edge3_id, edge_tuple, iedges = iter_edge(edge, EVinv, iedges)

        FEinds[i, :] = [edge1_id, edge2_id, edge3_id]

    end
    nedges = iedges
    return FEinds, EVinv, nedges
end

function convert_to_FElar(faces, FEinds, nfaces, nedges)
    FElar = spzeros(Int8, nfaces, nedges)
    for i = 1:nfaces
        face_orient = face_orientation(faces[i,:])
#         println(face_orient)
        edges_inds = FEinds[i,:]
        FElar[i, edges_inds[1]] = face_orient * 1
        FElar[i, edges_inds[2]] = face_orient * 1
        FElar[i, edges_inds[3]] = face_orient * -1

        #     face_orient = face_orientation(faces[i,:])
        #     face = sort(faces[i,:])
        #     edge = [face[1], face[2]]
        #     edge_tuple = tuple(edge[:]...)
    end
    return FElar

end


function get_FEinds_and_EVinds(faces, nfaces=nothing)
    if nfaces == nothing
        nfaces = size(faces,1)
    end
    FEinds, EVinv, nedges = get_FEinds_and_EVinv(faces, nfaces)
    EVinds = EVinv_to_EVinds(EVinv, nedges)
    return FEinds, EVinds
end

function convert_to_EVlar(EVinds, nedges, nvertices)
    EVlar = spzeros(Int8, nedges, nvertices)
    for i in 1:size(EVlar, 1)
        EVlar[i, EVinds[i, 1]] = -1
        EVlar[i, EVinds[i, 2]] = 1
    end
    return EVlar
end
#     FElar = get_FElar(faces, FEinds, nfaces, nedges)
#     return EVinds
# end

function get_EVlar_FElar(vertices, faces)
    FEinds, EVinds = get_FEinds_and_EVinds(faces)
    nedges = size(EVinds, 1)
    nfaces = size(faces, 1)
    nvertices = size(vertices, 1)
    FElar = convert_to_FElar(faces, FEinds, nfaces, nedges)
#     FElar = convert_to_FElar(faces, FEinds, nfaces, nedges)
    EVlar = convert_to_EVlar(EVinds, nedges, nvertices)

    return EVlar, FElar
end

function to_lar(vertices, faces)
    """
    :input: vertices, faces
    :output: V, EV, FE (LAR)
    """
    EVlar, FElar = get_EVlar_FElar(vertices, faces)
    return vertices, EVlar, FElar
end

function bool2sgn(bl)
    if (bl)
        a1 = 1
    else
        a1 = -1
    end

    return a1
end

function face_orientation(face)
    a1 = face[1] > face[2]
    a2 = face[2] > face[3]
    a3 = face[3] > face[1]
    signum = bool2sgn(a1) * bool2sgn(a2) * bool2sgn(a3)
    return signum
end
