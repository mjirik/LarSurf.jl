using Pio3d


function prepare_ircad(id=1)
    # fn = io3d.datasets.join_path("medical", "orig", "3Dircadb1.1", "MASKS_DICOM", "liver", get_root=True)
    pth = Pio3d.datasets_join_path("medical/orig/3Dircadb1.$id/MASKS_DICOM/liver")

    datap = Pio3d.read3d(pth)
    data3d_full = datap["data3d"]
    # round(size(data3d_full, 1) / target_size1)
    # return data3d_full
    data3d_int8 = convert(Array{Int8, 3}, data3d_full .> 0)
    @info "reading Ircad $id done"

    return data3d_int8
end

# im = prepare_ircad(2)
