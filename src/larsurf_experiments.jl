using Logging

"""
jlfile = @__FILE__
"""
function report_init_row(jlfile)
	using ExSu
    data = Dict()
    data["jlfile"] = jlfile
    data["nprocs"] = nprocs()
    data["nworkers"] = nworkers()
    data["hostname"] = gethostname()
    data["ncores"] = length(Sys.cpu_info())
	ExSu.datetime_to_dict!(data)
    return data
end

function report_add_data_info(data, segmentation, voxelsize_mm)

	data["data size 1"] = size(segmentation, 1)
	data["data size 2"] = size(segmentation, 2)
	data["data size 3"] = size(segmentation, 3)
	nvoxels = sum(segmentation)
	@info "nvoxels=$(nvoxels)"
	data["nvoxels"] = nvoxels
	data["voxelsize_mm 1"] = size(voxelsize_mm, 1)
	data["voxelsize_mm 2"] = size(voxelsize_mm, 2)
	data["voxelsize_mm 3"] = size(voxelsize_mm, 3)
	return data
end
