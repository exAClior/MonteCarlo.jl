using MonteCarlo
using Documenter

DocMeta.setdocmeta!(MonteCarlo, :DocTestSetup, :(using MonteCarlo); recursive=true)

makedocs(;
    modules=[MonteCarlo],
    authors="Yusheng Zhao",
    repo="https://github.com/exAClior/MonteCarlo.jl/blob/{commit}{path}#{line}",
    sitename="MonteCarlo.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://exAClior.github.io/MonteCarlo.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/exAClior/MonteCarlo.jl",
    devbranch="main",
)
