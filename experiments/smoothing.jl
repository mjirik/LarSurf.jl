using LarSurf
using JLD2

# created by surface_extraction_parallel_ircad01.jl
@load "liver01.jld2"

Vs = LarSurf.Smoothing.smoothing(V)
# Plasm.view(val)
ViewerGL.VIEW([
    ViewerGL.GLGrid(Vsm,FV,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
