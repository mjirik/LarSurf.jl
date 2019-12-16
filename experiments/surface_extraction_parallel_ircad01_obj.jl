using Revise
using JLD2
# using ViewerGL
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


# created by surface_extraction_parallel_ircad01.jl
# @load "liver01.jld2" V FV


# @JLD2.load "ircad_$(mask_label).jld2" V FV
# @JLD2.load "ircad_$(mask_label)_tri.jld2" V FVtri
mask_labels=["liver", "portalvein"]
# mask_labels=["liver"]
# pth = Pio3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/liver")

for mask_label in mask_labels

	@JLD2.load "ircad_$(mask_label)_sm.jld2" Vs FVtri
	println("size FVtri $(size(FVtri))")

	objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "ircad_$(mask_label)_taubin.obj")
	@info "length of obj $(size(objlines))"

	# save also non triangulated version
	@info "save data withouth smoothing"
	@JLD2.load "ircad_$(mask_label).jld2" V FV
	objlines = LarSurf.Lar.lar2obj(V, FVtri, "ircad_$(mask_label).obj")
end
# print(obj)
