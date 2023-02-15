using MonteCarlo, Test, Random

@testset "Monte Carlo Constructor" begin
    # dimension of space of be integrated over
    ndim = 3
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


    # figure out how do i test with know faulty input
    integrater = MCintegrate(ndim, xlo, xhi, insideChecker, [func1, func2, func3, func4])
    @test all(x -> isreal(x), [integrater.xlo..., xhi...])
    @test all(x -> x[1] <= x[2], collect(zip(integrater.xlo, integrater.xhi)))
    @test all(x -> length(x) == integrater.ndim, [integrater.xlo, integrater.xhi])
    @test integrater.step_taken == 0
    @test integrater.vol == prod(xhi .- xlo)


    # faulty boundaries
    xlo_int, xhi_int = [0, 1, 3], [2.0, 4.0, 5.0]
    @test_throws MethodError MCintegrate(
        ndim,
        xlo_int,
        xhi_int,
        insideChecker,
        [func1, func2, func3, func4],
    )

    xlo_f, xhi_f = [0.0, 1.0, 3.0], [-2.0, 4.0, 5.0]
    @test_throws AssertionError MCintegrate(
        ndim,
        xlo_f,
        xhi_f,
        insideChecker,
        [func1, func2, func3, func4],
    )

    @test_throws AssertionError MCintegrate(
        ndim,
        xlo[1:2],
        xhi,
        insideChecker,
        [func1, func2, func3, func4],
    )

    @test_throws AssertionError MCintegrate(
        2,
        xlo,
        xhi,
        insideChecker,
        [func1, func2, func3, func4],
    )

end

@testset "Monte Carlo Integrate" begin

    ndim = 2
    # boundaries of integration
    xlo, xhi = [-1.0, -1.0], [1.0, 1.0]

    insideChecker(x, y) = x^2 + y^2 <= 1.0 ? true : false

    # there might be multiples functions that we want to integrate in the same region
    func1(x, y) = 1 # integrates the area
    func2(x, y) = sqrt(1 - x^2 - y^2) # integrates the volume


    # for some seed, it does not converge as fast
    integrater = MCintegrate(ndim, xlo, xhi, insideChecker, [func1, func2],Xoshiro(1021))
    sample_NSteps!(integrater, 100000)
    ansVec, err = calc_answer!(integrater)
    trueAns = [π, π * 2 / 3]
    for i in 1:length(ansVec)
        # error is within 1.96 s.d, 95% confidence level
        @test isapprox(ansVec[i], trueAns[i], atol=1.96 * err[i])
    end
    # take 100000 more steps
    sample_NSteps!(integrater, 1000000)
    ansVec, err = calc_answer!(integrater)
    for i in 1:length(ansVec)
        # should still pass test
        @test isapprox(ansVec[i], trueAns[i], atol=1.96 * err[i])
    end


end
