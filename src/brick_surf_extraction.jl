function get_surface_grid_fixed_brick_size(segmentation::AbstractArray, block_size::ArrayOrTuple; return_all::Bool=false)

    Fchar = __grid_get_surface_Fchar_per_block(segmentation, block_size)
    #
    # data_size = lario3d.size_as_array(size(segmentation))
    # bigV, FVreduced = lario3d.grid_Fchar_to_V_FVreduced(Fchar, data_size)
    #
    # # return filtered_bigFV, Fchar, (bigV, model)
    #
    # if return_all
    #     return (bigV,[FVreduced]), Fchar, (bigV, [FVreduced])
    # else
    #     return (bigV,[FVreduced])
    # end
end
