using Revise
using JLD2
# using ViewerGL
# using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


# created by surface_extraction_parallel_ircad01.jl
# @load "liver01.jld2" V FV


mask_label = "liver"
# @JLD2.load "ircad_$(mask_label).jld2" V FV
# @JLD2.load "ircad_$(mask_label)_tri.jld2" V FVtri
@JLD2.load "ircad_$(mask_label)_sm.jld2" Vs FVtri
V = Vs

c = mask_label
# FVtri = LarSurf.triangulate_quads(FV)
# @load "{c}01tri.jld2" V FVtri
println("size FVtri $(size(FVtri))")

function lar2obj(V::Lar.Points, FVtri::Array)
    # copEV, copFE, copCF = cc
	# copEV = cc[1]
	# copFE = cc[2]
	lines = []
	if size(V,2) > 3
		V = convert(Lar.Points, V') # out V by rows
	end
    obj = ""
    for v in 1:size(V, 1)
		push!(lines,
	        string("v ",
	    	round(V[v, 1], digits=6), " ",
	    	round(V[v, 2], digits=6), " ",
	    	round(V[v, 3], digits=6), "\n")
		)
        # obj = string(obj, "v ",
    	# round(V[v, 1], digits=6), " ",
    	# round(V[v, 2], digits=6), " ",
    	# round(V[v, 3], digits=6), "\n")
    end

    # print("Triangulating")
    # triangulated_faces = Lar.triangulate(V, cc[1:2])
    # println("DONE")

    # for c in 1:copCF.m
		push!(lines,
        	string("\ng cell", c, "\n")
		)
        # for f in copCF[c, :].nzind
            # triangles = triangulated_faces[f]
			triangles = FVtri
            for tri in triangles
                #t = copCF[c, f] > 0 ? tri : tri[end:-1:1]
				t = tri
				push!(lines,
                	string("f ", t[1], " ", t[2], " ", t[3], "\n")
					)
            end
        # end
    # end

    return lines
end
objlines = lar2obj(V, FVtri)
@info "length of obj $(size(objlines))"
# print(obj)
open("output.obj", "w") do f
	for line in objlines
    	write(f, line)
	end
end

# tm1 = @elapsed EV1 = LarSurf.Smoothing.get_EV_quads(FVtri)
# tm2 = @elapsed EV2 = LarSurf.Smoothing.get_EV_quads2(FVtri)
# @info "time get EV" tm1 tm2
# # Plasm.view(val)
# ViewerGL.VIEW([
#     ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,0,1,1))
#     # ViewerGL.GLGrid(V,EV1,ViewerGL.Point4d(.9,0,.9,0.9))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])
#
# Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, 3)
#
# ViewerGL.VIEW([
#     ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,0,1,0.1))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])
#
# ViewerGL.VIEW([
#     ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,0,1,0.1))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])
