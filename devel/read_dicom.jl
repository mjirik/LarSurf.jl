using DICOM
# Dataset can be downloaded from here:
# https://www.ircad.fr/research/3d-ircadb-01/
# this is path where data on all my computers are stored
liverdir = homedir() * "/data/medical/orig/3Dircadb1.1/MASKS_DICOM/portalvein/"

filename_base="image_"

files = readdir(liverdir)
files_filtered = [fn for fn in files if findfirst(".", fn) == nothing ]

function get_int(fn)
    return parse(Int, fn[length(filename_base)+1:end])
end
files_sorted = sort(files_filtered, by=get_int)

dcmData = dcm_parse(liverdir * files_sorted[1])
image = dcmData[tag"Pixel Data"]
newdata = Array{UInt8, 3}(undef, length(files_sorted), size(image,1), size(image,2))
for i=1:length(files_sorted)
    dcmData = dcm_parse(liverdir * files_sorted[i])
    image = dcmData[tag"Pixel Data"]
    newdata[i, :, :] = image
end
