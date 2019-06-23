using Io3d


function prepare_sliver(id=1)
    # fn = io3d.datasets.join_path("medical", "orig", "3Dircadb1.1", "MASKS_DICOM", "liver", get_root=True)
    pth = Io3d.datasets_join_path("medical/orig/3Dircadb1.$id/MASKS_DICOM/liver")

    datap = Io3d.read3d(pth)
    data3d_full = datap["data3d"]
    # round(size(data3d_full, 1) / target_size1)
    return data3d_full > 0
end
