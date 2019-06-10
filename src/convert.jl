# const Union{}
# function convert(type::Tuple{Points, Array{Cells, 1}})
# end

using LinearAlgebraicRepresentation

# export convert

# @everywhere begin
    Lar = LinearAlgebraicRepresentation
    function convert(::Type{Lar.Cell}, cell::Lar.Cells)
        return Lar.characteristicMatrix(cell)
    end

    function convert(::Type{Lar.ChainOp}, cells::Lar.Cells)
        return Lar.lar2cop(cells)
    end

    function convert(::Type{Lar.Cells}, chainop::Lar.ChainOp)
        return Lar.cop2lar(chainop)
    end
# end
