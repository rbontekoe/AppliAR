using Documenter, AppliAR

makedocs(;
    modules=[AppliAR],
    format=Documenter.HTML(),
    pages=[
        "Accounts Receivable" => "index.md",
        "1 - Domain" => "chapter1.md",
        "2 - API" => "chapter2.md",
        "3 - Infrastructure" => "chapter3.md",
        "4 - Reporting" => "chapter4.md",
    ],
    repo="https://github.com/rbontekoe/AppliAR.jl/blob/{commit}{path}#L{line}",
    sitename="AppliAR.jl",
    authors="Rob Bontekoe",
    assets=String[],
)

deploydocs(;
    repo="github.com/rbontekoe/AppliAR.jl",
)
