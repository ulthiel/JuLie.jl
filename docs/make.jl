using Documenter, JuLie

makedocs(sitename = "JuLie Documentation", modules = [JuLie])

deploydocs(
    repo = "github.com/schto223/JuLie.jl.git",
)
