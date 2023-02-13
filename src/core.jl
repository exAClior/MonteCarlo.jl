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

function MCintegrate(
    ndim::Int,
    xlo::VT,
    xhi::VT,
    insideChecker::Function,
    funcs::Vector{Function},
) where {T<:Real,VT<:AbstractVector{T}}
    @assert length(xlo) == length(xhi) "Boundary size does not match"
    @assert ndim == length(xlo) "Integration Space Dimension does not match boundary dimension"
    @assert all(x -> x[1] <= x[2], collect(zip(xlo, xhi))) "Check Boundary order"
    MCintegrate(ndim, xlo, xhi, insideChecker, funcs, length(funcs), prod(xhi .- xlo), 0)
end
