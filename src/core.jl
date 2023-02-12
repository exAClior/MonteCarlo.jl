mutable struct MCintegrate{T<:Real,VT<:AbstractVector{T}}
    ndim::Int
    xlo::VT
    xhi::VT
    insideChecker::Function
    funcs::Vector{Function}
    nfunc::Int
    vol::T
    step_taken::Int
end

function MCintegrate(ndim::Int, xlo::VT, xhi::VT, insideChecker::Function, funcs::Vector{Function}) where {T<:Real,VT<:AbstractVector{T}}
    MCintegrate(ndim, xlo, xhi, insideChecker, funcs, length(funcs), prod(xhi .- xlo), 0)
end
