
# read_obj
function get_obj_metainfo(lines)
    """
    lines = readlines(open(filename))
    """

    nvertices = 0
    nfaces = 0
    for line in lines
        if line[1] == 'v'
            nvertices = nvertices + 1
#             print("v ", nvertices)
        elseif line[1] == 'f'
            nfaces = nfaces + 1
#             print("f ", nfaces, " ")
        end
#         print(line)
    end
    return nvertices, nfaces
end

function get_obj_vertices_and_faces(lines, nvertices, nfaces)
    vertices = Array(Float64, nvertices , 3)
    faces = Array(Int64, nfaces, 3)
#     println("vertices ", size(vertices))
#     println("faces ", size(vertices))
    ivertices = 1
    ifaces = 1

    for line in lines
#         println("ivertices and ifaces ", ivertices, " ",ifaces)
        lsplit = split(line)
        if line[1] == 'v'
            for i=2:4
                vertices[ivertices, i - 1] = parse(Float64, lsplit[i])
            end
    #         print(vertices[ivertices,:])
    #         println(line)
    #         println(vertices[1:10,:])

            ivertices = ivertices + 1
        elseif line[1] == 'f'
            for i=2:4
                faces[ifaces, i - 1] = parse(Int64, lsplit[i])
            end
            ifaces = ifaces + 1
        else
            println("Cannot parse: ", line)
        end
    end
    return vertices, faces
end

function read_obj(filename)

    f = open(filename);
    lines = readlines(f)
    nvertices, nfaces = get_obj_metainfo(lines)
#     println(nvertices, " ", nfaces)
    vertices, faces = get_obj_vertices_and_faces(lines, nvertices, nfaces)
#     println(nvertices, " ", nfaces)
    return vertices, faces
end

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

function get_FEinds_and_EVinv(faces, nfaces)
    """
    :faces: Array nfaces x 3

    Return
    FEinds: face to edge array. Contain indexes of edges
    EVinv: inverse edge to vertes. Dictionary where key is tuple with vertex index and value is edge id.
    """
# Create list of unique edges and create FEinds
# Keep order of vertex in faces. It is important for face orientation.
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
    EVlar, FElar = get_EVlar_FElar(vertices, faces)
    return vertices, EVlar, FElar
end

