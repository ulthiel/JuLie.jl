using Documenter, JuLie

DocMeta.setdocmeta!(JuLie, :DocTestSetup, :(using JuLie); recursive = true)

makedocs(
	#modules = [JuLie],
	format = Documenter.HTML(
		# Use clean URLs, unless built as a "local" build
		prettyurls = !("local" in ARGS),
		#canonical = "https://juliadocs.github.io/Documenter.jl/stable/",
	),
	sitename = "JuLie",
	authors = "Ulrich Thiel",
	pages = [
		"About" =>	[
			"index.md",
			"julia-crash-course.md",
			"contributing.md",
			"benchmarks.md"
			],

		"Basic algebraic structures" => "basic-algebraic-structures.md",

		"Combinatorics" => 	[
			"partitions.md",
			"combinatorics.md"
			],

		"Index" => "julie-index.md"
	]
)

deploydocs(
	repo = "github.com/ulthiel/JuLie.jl.git",
)
