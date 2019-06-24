
function triangulate_quads(FV::Array{Array{Int64, 1}, 1})

	# FV1 = [[f[1], f[3], f[4]] for f in FV]
	# FV2 = [[f[1], f[3], f[2]] for f in FV]
	# FVtri = vcat(FV1, FV2)
    return reshape([ [face[1], face[3], face[j+2]] for face in FV, j=0:2:2], :)
    # Array{Array{Int64,1},1}(undef, 5)
    # trifaces = Array{Int64}(undef, size(faces, 1) * 2, 3)
    # for i in 1:size(faces,1)
    #     face = faces[i,:]
    #     trifaces[(i * 2) - 0, :] = [face[1], face[2], face[3]]
    #     trifaces[(i * 2) - 1, :] = [face[1], face[3], face[4]]
    # end
    # return trifaces
end
