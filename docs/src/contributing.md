# Contributing

Contributions are necessary and very much welcome! Here is some help on how to do this. I have written this document for those who are very new to developing in Julia, so you may skip many things—but please at least read the [programming](@ref Programming) and [documenting](@ref Documenting) guidelines.

## Setting up the repository

If you have previously installed JuLie as described in the [installation](@ref Installation) section of the manual, you should remove it first to get a clean environment for developing: in Julia, hit the ```]``` key to enter the Pkg mode, type ```rm JuLie```, and exit Julia.

Everything around version control will be handled by [Git](https://git-scm.com/downloads) and you need to have this installed. A quick introduction to Git is [here](https://docs.gitlab.com/ee/gitlab-basics/start-using-git.html). To contribute, it's best to have a [GitHub](https://github.com) account and fork my [JuLie.jl](https://github.com/ulthiel/JuLie.jl) repository. Clone your fork to somewhere on your computer:

```
git clone https://github.com/YOUR_USERNAME/JuLie.jl
```

Enter the directory ```JuLie.jl``` of your clone, start Julia, hit the ```]``` key, and then register the package at this location for developing by typing

```
dev .
```

Exit the Pkg mode by hitting the backspace key. Then you can start using the package as usual with:

```
using JuLie
```

The idea of working with Git is that for any reasonable chunk of changes you do in the source code, you fix the state by doing a Git *commit* (with a reasonable description). Remeber to first add every new file via ```git add```. As a commit is only a local thing, you need to eventually *push* all your commits to your repository on GitHub. If you're asked for your GitHub username and passwort at every push, then [here](https://docs.github.com/en/get-started/getting-started-with-git/why-is-git-always-asking-for-my-password) is some advice on how to stop this.

To merge your repository into mine, you do a [pull request](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) on GitHub. But before you do this, please make sure that everything is well-documented, the documentation builds correctly, and all tests pass.

## Structure of JuLie

The source files are located in the [src](https://github.com/ulthiel/JuLie.jl/tree/master/src) directory. The main source file is [src/JuLie.jl](https://github.com/ulthiel/JuLie.jl/blob/master/src/JuLie.jl). Three things are happening here:

1. Importing structures and functions from other packages. I have decided to do the imports one by one instead of doing a full import of everything from, e.g., OSCAR, to keep JuLie slick and have maximal control. All these structures and functions can be used directly in the JuLie code. If necessary, you may add more imports here (as long as you're developing and haven't finally decided on what you actually need, I recommend putting the new imports in the source file you're working on first).
2. Exporting structures and functions. This only concerns exports of some of the imports above and I am doing this for convenience so that, e.g., one can directly create a polynomial ring from within JuLie without having to load AbstractAlgebra or Nemo first. The exports of functions implemented in JuLie itself are located in the various source files.
3. Inclusion of all the various source files of JuLie.

To ensure proper functionality of JuLie we use [unit testing](https://docs.julialang.org/en/v1/stdlib/Test/). The directory [test](https://github.com/ulthiel/JuLie.jl/tree/master/test) contains various test sets, and these are combined in the file [runtests.jl](https://github.com/ulthiel/JuLie.jl/blob/master/test/runtests.jl). You can run the complete unit test with ```Pkg.test("JuLie")```.

The documentation is automatically built on GitHub using the package [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) from the comments in the source files together with the Markdown files in the [docs/src](https://github.com/ulthiel/JuLie.jl/tree/master/docs) directory. The file [docs/make.jl](https://github.com/ulthiel/JuLie.jl/blob/master/docs/make.jl) defines the structure of the navigation panel. You can build the documentation locally by running ```julia make.jl local```; the result is then in the build directory.

## Programming

If you are completely new to Julia, I recommend reading my Julia [crash course](@ref julia-crash). Eventually, you will need to look things up in the official Julia [documentation](https://docs.julialang.org/en/v1/). I recommend browsing through some of the source files of JuLie to get a quick impression of the programming style. Here are some guidelines:

1. We follow the official Julia [style guide](https://docs.julialang.org/en/v1/manual/style-guide/) (except for the next point).
2. We use *one hard tab* for indentation.
3. Unicode in the source code is allowed and encouraged to increase readability. The [LaTex-like abbreviations](https://docs.julialang.org/en/v1/manual/unicode-input/) for unicode characters can be used in, e.g., the [Atom](https://atom.io) editor.
4. Remember that we want to use [basic algebraic structures](@ref basic-alg-struct) provided by (subpackages of) OSCAR.
5. Mathematical structures you implement should somehow reflect how they are defined and treated abstractly. This is often easier said than done and one really needs to think about this *before* implementing anything.
6. If your implementation is not faster than those in other computer algebra systems then it's not good enough. (Don't take this too seriously, but at least try. I prefer to have a not incredibly fast algorithm than no algorithm at all, especially if the structures are mathematically sound so that we can improve functions at a later stage without having to do structural changes). Please read the Julia [performance guide](https://docs.julialang.org/en/v1/manual/performance-tips/) to not fall into typical traps.
7. For every function you implement, you should add a reasonable test to the unit testing. Try to find computed examples in publications or which follow from general theory etc.

## Documenting

Everything has to be well-documented, algorithms and papers have to be properly referenced. Here are some guidelines:

1. To express mathematics in the documentation we use unicode, and for the more complicated things we combine this with LaTeX. Here's an example of how this is done:

   ```julia
   @doc raw"""
   	quantum_integer(n::Int, q::RingElem)
   Let ``n ∈ ℤ`` and let ``ℚ(𝐪)`` be the fraction field of the polynomial ring ``ℤ[𝐪]``...
   """
   function quantum_integer(n::Int, q::RingElem)
     ...
   end
   ```

   Everything between the ``` `` ``` is interpreted as LaTex. You can add similar comments for structures. The comments can be integrated in the documentation by adding the function (or structure) name to the Markdown files in the [docs/src](https://github.com/ulthiel/JuLie.jl/tree/master/docs/src) directory.

2. We use an "Examples" section in the documentation block to give some examples.

3. We use a "References" section at the end of a documentation block to list references. The references are given in [APA style](https://en.wikipedia.org/wiki/APA_style), e.g. "Etingof, P. & Ginzburg, V. (2002). Symplectic reflection algebras, Calogero-Moser space, and deformed Harish-Chandra homomorphism. *Invent. Math., 147*(2), 243–348. [https://doi.org/10.1007/s002220100171](https://doi.org/10.1007/s002220100171)". In-text references in APA style look like "Etingof & Ginzburg (2002)". You can use [BibDesk](https://bibdesk.sourceforge.io) and my [APA export template](https://gist.github.com/ulthiel/3ecbc5b9e95beae896958028a0e42ca4) to save time dealing with this.

## The Revise package

If you have a running Julia session with JuLie loaded, then changes you make to the JuLie code will have no effect in the running Julia session—you have to restart it. This is simply the way Julia works. But this is annoying when developing. A solution is to use the [Revise](https://timholy.github.io/Revise.jl/v0.6/) package. You can install it with

```julia-repl
using Pkg
Pkg.add("Revise")
```

and then you need to load it *before* loading the package you're working on:

```julia-repl
using Revise
using JuLie
```

Now, changes you make in the code are immediately available in the running Julia session (except for changes to structures, here you still need to restart).
