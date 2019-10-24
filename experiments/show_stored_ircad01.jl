using Revise
using JLD2
using ViewerGL
using LarSurf

# created by surface_extraction_parallel_ircad01.jl
@load "liver01.jld2" V FV


FVtri = LarSurf.triangulate_quads(FV)
EV = LarSurf.Smoothing.get_EV_quads(FV)
# Plasm.view(val)
ViewerGL.VIEW([
    # ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,0,1,0.1))
    ViewerGL.GLGrid(V,EV,ViewerGL.Point4d(0.5,0,1,0.5))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
