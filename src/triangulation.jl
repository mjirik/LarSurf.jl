
function triangulate_quads(FV::Array{Array{Int64, 1}, 1})
    return reshape([ [face[j], face[j+1], face[j+2]] for face in FV, j=1:2], :)
    # Array{Array{Int64,1},1}(undef, 5)
    # trifaces = Array{Int64}(undef, size(faces, 1) * 2, 3)
    # for i in 1:size(faces,1)
    #     face = faces[i,:]
    #     trifaces[(i * 2) - 0, :] = [face[1], face[2], face[3]]
    #     trifaces[(i * 2) - 1, :] = [face[1], face[3], face[4]]
    # end
    # return trifaces
end
