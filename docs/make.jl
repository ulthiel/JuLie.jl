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
			"contributing.md",
			"benchmarks.md",
			"julia-crash.md"
			],

		"Basic algebraic structures" => "basic-alg-struct.md",

		"Combinatorics" => 	[
			"combinatorics.md",
			"partitions.md"
			],

		"Lie theory" => "lie-theory.md",

		"Index" => "julie-index.md"
	]
)

deploydocs(
	repo = "github.com/ulthiel/JuLie.jl.git",
)
