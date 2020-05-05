using Documenter, AppliAR

makedocs(;
    modules=[AppliAR],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/rbontekoe/AppliAR.jl/blob/{commit}{path}#L{line}",
    sitename="AppliAR.jl",
    authors="Rob Bontekoe",
    assets=String[],
)

deploydocs(;
    repo="github.com/rbontekoe/AppliAR.jl",
)
