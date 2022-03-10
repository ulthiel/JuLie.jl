using Documenter, JuLie

DocMeta.setdocmeta!(JuLie, :DocTestSetup, :(using JuLie); recursive = true)

makedocs(
    #modules = [JuLie],
    format = Documenter.HTML(
        # Use clean URLs, unless built as a "local" build
        prettyurls = !("local" in ARGS),
        #canonical = "https://juliadocs.github.io/Documenter.jl/stable/",
        collapselevel=1
    ),
    sitename = "JuLie",
    authors = "Ulrich Thiel",
    pages = [
        "About" => [
            "index.md",
            "about/motivation.md",
            "about/introduction-to-julia.md",
            "about/integer-remarks.md",
            "about/contributing.md",
            "about/benchmarks.md"
            ],

        "Algebraic structures" => [
            "algebraic-structures/oscar.md"
            ],

        "Combinatorics" => [
            "combinatorics/compositions.md",
            "combinatorics/multipartitions.md",
            "combinatorics/multiset-partitions.md",
            "combinatorics/partitions.md",
            "combinatorics/tableaux.md",
            ],

        "Index" => "julie-index.md",
    ]
)

deploydocs(
    repo = "github.com/ulthiel/JuLie.jl.git",
)
