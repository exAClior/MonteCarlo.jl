using MonteCarlo, Test

@testset "Monte Carlo Integrator" begin
    # dimension of space of be integrated over
    ndim, nfunc, step_taken = 3, 4, 0
    # boundaries of integration
    xlo, xhi = [-5.0, -5.0, -5.0], [5.0, 5.0, 5.0]

    # function that defines
    function insideChecker(x, y, z)
        # series of condition defined by user
        cond1 = z^2 + (sqrt(x^2 + y^2) - 3)^2 <= 1 ? true : false
        cond2 = x >= 1 ? true : false
        cond3 = y >= -3 ? true : false
        return cond1 && cond2 && cond3
    end

    # there might be multiples functions that we want to integrate in the same region
    func1(x, y, z) = 1
    func2(x, y, z) = x
    func3(x, y, z) = y
    func4(x, y, z) = z



    integrater = MCintegrate(ndim, xlo, xhi, insideChecker, [func1, func2, func3, func4])
    @test all(x -> isreal(x), [integrater.xlo..., xhi...])
    @test all(x -> x[1] <= x[2], collect(zip(integrater.xlo, integrater.xhi)))
    @test all(x -> length(x) == integrater.ndim, [integrater.xlo, integrater.xhi])
    @test integrater.step_taken == 0
    @test integrater.vol == prod(xhi .- xlo)
end
