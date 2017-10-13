function remove_double_vertexes_alternative(V)
    """ Return reduced vertex list wiht search table.

    Alternativte removing of doublefaces. Hopefully more memory efficient
    """
    test_vertex = V

    X = range(1, size(V,1))
    # Vs = [v for (v, x) in VIsorted]
    # Is = [x for (v, x) in VIsorted]
    Vs = []
#     Is = [0]*size(V, 1)
#     Is = zeros( Int64, size(test_vertex, 1))

    Is = Dict()

    prevv = nothing
    i = 1
    sorted_vertex_id_x = sortperm(collect(zip(test_vertex[:,1], test_vertex[:,2])))
               sortperm(collect(zip(test_vertex[:,1], test_vertex[:,2])))
#     for couple in sort(collect(zip(X, conv2array_of_float_arrays(V))))
    for x in sorted_vertex_id_x
        v = V[x,:]
#         x =
#         x, v = couple
#         println(v, prevv, v.==prevv)
        if v == prevv
            # prev index was increased
            Is[x] = i - 1
        else
            push!(Vs, v)
            Is[x] = i
            i = i + 1
            prevv = v
        end
    end

    vertex_reduced_list = Vs
    vertex_search_table = Is
    return vertex_reduced_list, vertex_search_table
end

function reindexVertexesInFaces(faces, new_indexes,
                                       index_base=0)
#     println(faces)
    for i in 1:size(faces, 1)
        for j in 1:size(faces, 2)
            faces[i, j] = new_indexes[faces[i, j] - index_base] + index_base
        end
    end
#     try
#     catch
#         println("reindexVertexInFaces exception")
#         println("fc ", face, " i ", i , " len ", size(new_indexes))

#     end
    return faces

end

function removeOneOfDoubleFacesByDictAlgoritm(FW, sort_faces=true)
    """
    Remove one of doubled face. Probably not usefull function.
    remove_DoubleFacesByAlberto() is probably what you are looking for.
    """
#     FWdict = Dict()
    set = Set()
    for k in 1:size(FW, 1)
        # println(k)
        if sort_faces
            face = tuple(sort(FW[k, :])...)
        else
            face = tuple(FW[k, :]...)
        end

        push!(set, face)
    end
    return set
end


function removeDoubleFacesByAlberto(FW, sort_faces=true)
    """
    Remove inner (doubled) faces
    """

    # Find which are doubled
    FWdict = Dict()
    FWdict_size = 0
    for k in 1:size(FW, 1)
#         println(k)
        if sort_faces
            face = tuple(sort(FW[k, :])...)
        else
            face = tuple(FW[k, :]...)
        end
        if haskey(FWdict, face)


            # FWdict[face] = FWdict[face] + 1
            push!(FWdict[face], k)
            FWdict_size -= 1
        else
            FWdict[face] = [k]
            FWdict_size += 1
        end

    #     push!(set, face)
    end

    # create new FW using just single used

    FW_no_double = Array(eltype(FW), FWdict_size, size(FW, 2))

    i = 0
    for face_pair in FWdict
        face_key, face_value = face_pair
        if size(face_value, 1) == 1
            i += 1
            for j in 1:size(FW, 2)
                FW_no_double[i, j] = FW[face_value[1], j]
                # FW_no_double[i, j] = face_key[j]
            end
        else
            # println("Removed face ", face_value, FW, face_value[1])
        end

    end
    return FW_no_double

end

