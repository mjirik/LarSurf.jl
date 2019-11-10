using Revise
using JLD2
using ViewerGL
using LarSurf

# created by surface_extraction_parallel_ircad01.jl

mask_labels = ["portalvein", "liver"]
mask_labels = ["liver"]
views = []
view = ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
push!(views, view)

for mask_label in mask_labels
	@info "mask_label: $mask_label"
	@load "ircad_$(mask_label)_sm.jld2" Vs FVtri

    view = ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	push!(views, view)
end

ViewerGL.VIEW(views)
