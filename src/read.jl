
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

