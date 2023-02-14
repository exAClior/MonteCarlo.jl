mutable struct MCintegrate{T<:AbstractFloat,VT<:AbstractVector{T}}
    ndim::Int
    xlo::VT
    xhi::VT
    insideChecker::Function
    funcs::Vector{Function}
    nfunc::Int
    vol::T
    step_taken::Int
    ff::VT    #  integration results and
    fferr::VT #  estimated errors to be updated by calc_answer
    f_avg::VT # average of sampled function value,
    fsq_avg::VT #  average of sample function squared value
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
    MCintegrate(
        ndim,
        xlo,
        xhi,
        insideChecker,
        funcs,
        length(funcs),
        prod(xhi .- xlo),
        0,
        zeros(eltype(xlo), length(funcs)),
        zeros(eltype(xlo), length(funcs)),
        zeros(eltype(xlo), length(funcs)),
        zeros(eltype(xlo), length(funcs)),
    )
end


function sample_NSteps!(mci::MCintegrate, nstep::Int; rng::AbstractRNG = Xoshiro(0))
    # generate the random positions
    xs = rand(rng, eltype(mci.xlo), (mci.ndim, nstep))
    for i = 1:nstep
        xs[:, i] .*= (mci.xhi .- mci.xlo)
        xs[:, i] .+= mci.xlo
    end

    cur_f_avg = zeros(eltype(mci.xlo), mci.nfunc)
    cur_fsq_avg = zeros(eltype(mci.xlo), mci.nfunc)
    cur_fct = nstep / (mci.step_taken + nstep)
    prev_fct = 1 - cur_fct
    for i = 1:nstep
        if mci.insideChecker(xs[:, i]'...)
            for j = 1:mci.nfunc
                cur_f_avg[j] += cur_fct * mci.funcs[j](xs[:, i]'...)
                cur_fsq_avg[j] += cur_fct * (mci.funcs[j](xs[:, i]'...))^2
            end
        end
    end

    mci.f_avg .*= prev_fct
    mci.f_avg .+= cur_f_avg
    mci.fsq_avg .*= prev_fct
    mci.fsq_avg .+= cur_fsq_avg

    mci.step_taken += nstep
end


function calc_answer!(mci::MCintegrate)
    mci.ff = mci.vol .* mci.f_avg
    mci.fferr = mci.vol .* sqrt.((mci.fsq_avg .- (mci.f_avg) .^ 2 / mci.step_taken))
    return mci.ff, mci.fferr
end
