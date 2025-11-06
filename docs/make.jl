using PowerDynData
using Documenter

DocMeta.setdocmeta!(PowerDynData, :DocTestSetup, :(using PowerDynData); recursive=true)

makedocs(;
    modules=[PowerDynData],
    authors="Hantao Cui",
    sitename="PowerDynData.jl",
    format=Documenter.HTML(;
        canonical="https://cuihantao.github.io/PowerDynData.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cuihantao/PowerDynData.jl",
    devbranch="main",
)
