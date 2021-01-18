using Documenter, JuLie

#makedocs(sitename = "JuLie Documentation", modules = [JuLie])

#makedocs(
#    modules = [JuLie],
#    format = Documenter.HTML(
#        # Use clean URLs, unless built as a "local" build
#        prettyurls = !("local" in ARGS),
#        canonical = "https://juliadocs.github.io/Documenter.jl/stable/",
#    ),
#    sitename = "JuLie.jl",
#    authors = "Ulrich Thiel",
#    pages = [
#        "About" => "index.md",
#        "Combinatorics" => "combinatorics.md",
#        "Lie theory" => "lie-theory.md"
#    ]
#)

makedocs(sitename = "JuLie Documentation", modules = [JuLie])

deploydocs(
    repo = "github.com/schto223/JuLie.jl.git",
)
