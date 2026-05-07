using Tyst
using Documenter

DocMeta.setdocmeta!(Tyst, :DocTestSetup, :(using Tyst); recursive=true)

makedocs(;
    modules=[Tyst],
    authors="C. Naaktgeboren",
    sitename="Tyst.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
