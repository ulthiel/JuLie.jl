using Documenter, JuLie

#makedocs(sitename = "JuLie Documentation", modules = [JuLie])

DocMeta.setdocmeta!(JuLie, :DocTestSetup, :(using JuLie); recursive = true)

makedocs(
    modules = [JuLie],
#    format = Documenter.HTML(
#        # Use clean URLs, unless built as a "local" build
#        prettyurls = !("local" in ARGS),
#        canonical = "https://juliadocs.github.io/Documenter.jl/stable/",
#    ),
    sitename = "JuLie Documentation",
#    authors = "Ulrich Thiel",
    pages = [
        "About" => "index.md",
        "Combinatorics" => "combinatorics.md",
        "Lie theory" => "lie-theory.md"
    ]
)

deploydocs(
    repo = "github.com/ulthiel/JuLie.jl.git",
)
