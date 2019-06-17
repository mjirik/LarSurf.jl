# const Union{}
# function convert(type::Tuple{Points, Array{Cells, 1}})
# end

# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation

# export convert

# @everywhere begin
    function convert(::Type{Lar.Cell}, cell::Lar.Cells)
        # using LinearAlgebraicRepresentation
        # Lar = LinearAlgebraicRepresentation
        return Lar.characteristicMatrix(cell)
    end

    function convert(::Type{Lar.ChainOp}, cells::Lar.Cells)
        # using LinearAlgebraicRepresentation
        # Lar = LinearAlgebraicRepresentation
        return Lar.lar2cop(cells)
    end

    function convert(::Type{Lar.Cells}, chainop::Lar.ChainOp)
        # using LinearAlgebraicRepresentation
        # Lar = LinearAlgebraicRepresentation
        return Lar.cop2lar(chainop)
    end
# end
