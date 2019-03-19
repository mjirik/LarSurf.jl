#=
surface_extraction:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
function get_surface_grid(segmentation)
    segClin = lario3d.block_to_linear(segmentation, 0)

    block_size = size(segmentation)

    b3, V, model = lario3d.get_boundary3(block_size)

    # Matrix(b3)

    Flin = segClin' * b3
    # Matrix(Flin)
    lario3d.sparse_filter!(Flin, 1, 1, 0)
    dropzeros!(Flin)

    (VV, EV, FV, CV) = model
    # Flin = segClin' * b3

    filteredFV = [FV[i] for i=1:length(Flin) if (Flin[i] == 1)]
    return filteredFV, Flin, V, model
end
