using Revise
using JLD2
using ViewerGL
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


# created by surface_extraction_parallel_ircad01.jl
@load "liver01.jld2" V FV


FVtri = LarSurf.triangulate_quads(FV)

@load "liver01tri.jld2" V FVtri


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
