function import_data3d(data3d, voxelsize_mm, threshold=0)
    """
    Import 3d data to obj vertex and triangulated faces.
    """
    verts, nvoxels = vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm, threshold)
    faces = create_square_faces(data3d, nvoxels, threshold)
    new_verts, new_faces = keep_surface_faces(verts, faces)
    trifaces = triangulation(faces)
    check_vf(verts, trifaces)
    return verts, triface
end

# Get all vertices and count the voxels
function get_index(sz, i, j, k)
    index = 1 + i + (1 + sz[1]) * j + (sz[1] + 1) * (sz[2] + 1) * k
    return index
end

function vertices_and_count_voxels_as_the_square_face_preprocessing(data3d, voxelsize_mm, threshold=0)
    """

    Fill the area with all possible vertices. Most of them will be removed in future.
    """
    threshold = 0
    ivertex = 0
    ifaces = 0
    sz = size(data3d)
    verts = Array(Float64, (sz[1]+1) * (sz[2]+1) * (sz[3]+1), 3)
    # produce vertexes
    nvoxels = 0
    for k in 0:sz[3]
        for j in 0:sz[2]
            for i in 0:sz[1]
                if (i > 0) & (j > 0) & (k > 0)
                    if data3d[i,j,k] > threshold
                        nvoxels += 1
                    end
                end
                pt = get_index(sz, i - 0, j -0, k -0)
    #             println(pt)
                verts[pt, 1] = i * voxelsize_mm[1]
                verts[pt, 2] = j * voxelsize_mm[2]
                verts[pt, 3] = k * voxelsize_mm[3]
            end
        end
    end
    return verts, nvoxels
end


#
#
#       14 -------- 13
#     / |          / |
#   /   |        /   |
# 11 --------- 12    |
# |     |       |    |        i
# |     |       |    |
# |     24 -----|-- 23        |
# |   /         |   /         |   /
# | /           | /           | /
# 21 --------- 22             * ------
#
#
function create_square_faces(data3d, nvoxels, threshold=0)
    """
    create square faces based on vertices from vertices_and_count_voxels_as_...
    :nvoxels: number of voxels higher than the threslold.
    """
    nfaces = nvoxels * 6
    faces = Array(Int64, nfaces, 4)
    sz = size(data3d)
    ifaces = 0
#     println(sz)
    # produce faces
    for k in 1:sz[3]
        for j in 1:sz[2]
            for i in 1:sz[1]
    #             println(i,",",j,",",k)
                if data3d[i,j,k] > threshold
    #                 println("jsme uvnitr")
                    pt11 = get_index(sz, i -0, j -0, k -0)
    #                 println("jsme uvnitr", pt11)
                    pt12 = get_index(sz, i -0, j -0, k -1)
                    pt13 = get_index(sz, i -0, j -1, k -1)
                    pt14 = get_index(sz, i -0, j -1, k -0)
                    pt21 = get_index(sz, i -1, j -0, k -0)
                    pt22 = get_index(sz, i -1, j -0, k -1)
                    pt23 = get_index(sz, i -1, j -1, k -1)
                    pt24 = get_index(sz, i -1, j -1, k -0)

                    faces[ifaces + 1, :] = [pt11, pt12, pt13, pt14]'
                    faces[ifaces + 2, :] = [pt22, pt23, pt13, pt12]
                    faces[ifaces + 3, :] = [pt21, pt22, pt12, pt11]
                    faces[ifaces + 4, :] = [pt14, pt13, pt23, pt24]
                    faces[ifaces + 5, :] = [pt11, pt14, pt24, pt21]
                    faces[ifaces + 6, :] = [pt21, pt24, pt23, pt22]
                    ifaces += 6

                end
            end
        end
    end
    return faces
end

function arrayofarray2arrayd2d(d)
    data = Array(Float64,length(d),length(d[1]))
    for i in 1:length(d)
        for j in 1:length(d[1])
            data[i,j] = d[i][j]
        end
    end
    return data
end

function keep_surface_faces(vertexes, faces, index_base=0)
#     removeDoubleVertexesAndFaces
    # println("step1")
    new_vertexes, inv_vertexes = remove_double_vertexes_alternative(vertexes)# , index_base=index_base)
    # println("step2")
    new_faces = reindexVertexesInFaces(faces, inv_vertexes)
    # println("step3")
    new_faces = removeDoubleFacesByAlberto(faces)
    # println("step1")
    # todo remove unused vertexes
#     new_new_vertexes, new_new_inv_vertexes = remove_double_vertexes_alternative(new_vertexes)# , index_base=index_base)
    # println("step2")
#     new_faces = reindexVertexesInFaces(faces, inv_vertexes)
    new_vertexes = arrayofarray2arrayd2d(new_vertexes)
    return new_vertexes, new_faces
end
#             if segmentation[i,j,k]
function triangulation(faces)
    trifaces = Array(Int64, size(faces, 1) * 2, 3)
    for i in 1:size(faces,1)
        face = faces[i,:]
        trifaces[(i * 2) - 0, :] = [face[1], face[2], face[3]]
        trifaces[(i * 2) - 1, :] = [face[1], face[3], face[4]]
    end
    return trifaces
end


function thresholding(data3d, threshold)
    sz = size(data3d)
    segmentation = Array(Int8, size(data3d, 1), size(data3d, 2), size(data3d, 3))
    # produce vertexes
    for k in 1:sz[3]
        for j in 1:sz[2]
            for i in 1:sz[1]
                if data3d[i, j, k] > 0

                    segmentation[i, j, k] = data3d[i, j, k] > threshold
    #             if i == 0
    #             index = 1 + i + sz[1] * j + sz[1] * sz[2] * k
                end

            end
        end
    end
    return segmentation
end




