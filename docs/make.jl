using PowerDynData
using Documenter

# Generate model documentation from YAML metadata
include("generate_models.jl")
output_dir = joinpath(@__DIR__, "src", "models")
generate_model_docs(output_dir)

DocMeta.setdocmeta!(PowerDynData, :DocTestSetup, :(using PowerDynData); recursive=true)

makedocs(;
    modules=[PowerDynData],
    authors="Hantao Cui",
    sitename="PowerDynData.jl",
    format=Documenter.HTML(;
        canonical="https://cuihantao.github.io/PowerDynData.jl",
        edit_link="main",
        assets=String[],
        sidebar_sitename=false,
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Model Library" => [
            "Overview" => "models/index.md",
            "Generators" => "models/generators.md",
            "Exciters" => "models/exciters.md",
            "Governors" => "models/governors.md",
            "Stabilizers" => "models/stabilizers.md",
            "Voltage Compensators" => "models/voltage_compensators.md",
            "Renewable Energy" => "models/renewable_energy.md",
        ],
        "API Reference" => "api.md",
        "For Developers" => "developers.md",
    ],
    warnonly=[:missing_docs],
)

deploydocs(;
    repo="github.com/cuihantao/PowerDynData.jl",
    devbranch="main",
)
