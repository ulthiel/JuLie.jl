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
		"About" =>	[
			"index.md",
			"about/julia-crash-course.md",
			"about/contributing.md",
			"about/benchmarks.md"
			],

		"Basic algebraic structures" => "basic-algebraic-structures.md",

		"Combinatorics" => 	[
			"combinatorics/compositions.md",
			"combinatorics/multipartitions.md",
			"combinatorics/multiset-partitions.md",
			"combinatorics/partitions.md",
			"combinatorics/tableaux.md",
			],

		"Index" => "julie-index.md"
	]
)

deploydocs(
	repo = "github.com/ulthiel/JuLie.jl.git",
)
