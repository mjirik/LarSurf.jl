using Revise
using JLD2
using ViewerGL
using LarSurf

# created by surface_extraction_parallel_ircad01.jl
@load "liver01.jld2" V FV


FVtri = LarSurf.triangulate_quads(FV)
# Plasm.view(val)
ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,0,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])

Vs = LarSurf.Smoothing.smoothing_FV(V, FV, 0.6)

ViewerGL.VIEW([
    ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,0,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
Lar
