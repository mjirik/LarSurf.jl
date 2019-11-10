using Revise
using JLD2
# using ViewerGL
using LarSurf

show = false
taubin = true
mask_labels = ["liver", "portalvein"]
mask_labels = ["liver"]
# created by surface_extraction_parallel_ircad01.jl
if show
	using ViewerGL
end

for mask_label in mask_labels
	@info "mask_label: $mask_label"
	@load "ircad_$(mask_label).jld2" V FV
# @load "liver01.jld2" V FV


	t = @elapsed FVtri = LarSurf.triangulate_quads(FV)
	@info "triangulate quads time", t

	@JLD2.save "ircad_$(mask_label)_tri.jld2" V FVtri
	if show
		ViewerGL.VIEW([
		    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.9))
		    # ViewerGL.GLGrid(V,FVtri, 1)
		    # ViewerGL.GLGrid(V,EV1,ViewerGL.Point4d(.9,0,.9,0.9))
			ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
		])
	end

	if taubin
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV_taubin(V, FV, 0.6, -0.3, 50)
		@info "smoothing taubin time", t
		# t = @elapsed FVtri = LarSurf.triangulate_quads(FV)

		if show
			ViewerGL.VIEW([
			    ViewerGL.GLGrid(Vs, FVtri, ViewerGL.Point4d(1,0,1,0.1))
				ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
			])
		end
	else
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, 3)
		@info "smoothing time", t
	end
	@info "Smoothing numer of Vs: $(size(Vs))"
	@JLD2.save "ircad_$(mask_label)_sm.jld2" Vs FVtri

	# tm1 = @elapsed EV1 = LarSurf.Smoothing.get_EV_quads(FVtri)
	# # tm2 = @elapsed EV2 = LarSurf.Smoothing.get_EV_quads2(FVtri)
	# # @info "time get EV" tm1 tm2
	# @info "calculate EV", t


	if show
		ViewerGL.VIEW([
		    ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,1,1,0.1))
			ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
		])
	end


end
# ViewerGL.VIEW([
#     ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,0,1,0.1))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])
