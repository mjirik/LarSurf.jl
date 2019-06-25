using LarSurf
using JLD2
using ViewerGL

# created by surface_extraction_parallel_ircad01.jl
@load "liver01.jld2" V FVtri

Vs = LarSurf.Smoothing.smoothing_FV(V, FV, 0.6)
# Plasm.view(val)
ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,0,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
