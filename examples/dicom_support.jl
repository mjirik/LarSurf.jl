
using DICOM
function read_dicom_dir(dicomdir, filename_base="image_")
    datap = Dict()
    filename_base = "image_"
    dicomdir="C:\\Users\\Jirik/data/medical/orig/3Dircadb1.1/MASKS_DICOM/portalvein/"
    files = readdir(dicomdir)
    files_filtered = [fn for fn in files if findfirst(".", fn) == nothing ]

    function get_int(fn)
        return parse(Int, fn[length(filename_base)+1:end])
    end
    files_sorted = sort(files_filtered, by=get_int)

    dcmData = dcm_parse(dicomdir * files_sorted[1])
    image = dcmData[tag"Pixel Data"]
    pxsp = dcmData[tag"Pixel Spacing"]
    slth = dcmData[tag"Slice Thickness"]
    datap["voxelsize_mm"] = [slth, pxsp[1], pxsp[2]]
    # slloc1 = dcmData[tag"Slice Location"]
    # if length(files_sorted) > 1
    #     dcmData2 = dcm_parse(dicomdir * files_sorted[2])
    #     # slloc2 = dcmData2[tag"Slice Location"]
    #     datap["voxelsize_mm"] = [abs(slloc2 - slloc1), pxsp[1], pxsp[2]]
    #
    # else
    #     datap["voxelsize_mm"] = [pxsp[1], pxsp[2]]
    # end

    newdata = Array{eltype(image), 3}(undef, length(files_sorted), size(image,1), size(image,2))
    for i=1:length(files_sorted)
        dcmData = dcm_parse(dicomdir * files_sorted[i])
        image = dcmData[tag"Pixel Data"]
        newdata[i, :, :] = image
    end
    datap["data3d"] = newdata
    return datap
end
