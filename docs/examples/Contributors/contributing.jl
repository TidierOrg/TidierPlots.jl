
# ## Contribute to Documentation

# Examples are written and rendered using [Literate.jl](https://github.com/fredrikekre/Literate.jl).
# This allows you to write your example in a `.jl` file and annotate it with markdown.

# Contributing with examples can be done by first creating a new example file in the
# [docs/examples/UserGuide](https://github.com/TidierOrg/TidierPlots.jl/tree/main/docs/examples/UserGuide)
# directory:

# - `your_new_file.jl` at `docs/examples/UserGuide/`

# Once this is done you need to add a new nav entry to the
# [mkdocs.yml](https://github.com/TidierOrg/TidierPlots.jl/blob/main/docs/mkdocs.yml) file
# at the bottom at the appropriate level:

# Your new entry should look like:
# - `"Your title example" : "examples/generated/UserGuide/your_new_file.md"`


# ## Build docs locally

# If you want to take a look at the docs locally before doing a PR, then follow the next steps:

# ### Build docs locally
# Install the following dependencies in your system via pip, i.e.
# - `pip install mkdocs pygments python-markdown-math`
# - `pip install mkdocs-material pymdown-extensions mkdocstrings`
# - `pip install mknotebooks pytkdocs_tweaks mkdocs_include_exclude_files jinja2 mkdocs-video`

# Next you will need to activate the `docs` environment:

# ```
# TidierPlots.jl> julia --project=docs/ -e 'using Pkg; pkg"dev ."; Pkg.instantiate()'
# ```

# Generate files and build the docs by running the following in your terminal:

# ```
# TidierPlots.jl> julia --project=docs/ --color=yes docs/genfiles.jl
# TidierPlots.jl> julia --project=docs/ --color=yes docs/make.jl
# ```

# !!! info "Set environment variables"
#     You may want to set additional Julia environment variables before running `make.jl`.
#     This will enable additional debugging messages while building the docs.
#     - `ENV["JULIA_DEBUG"] = "Documenter"`

# Finally, in your `terminal`, change directory to the `docs` folder and run:

# ```
# docs> mkdocs serve
# ```

# This should output `http://127.0.0.1:8000`, copy/paste this into your browser and you are
# all set. You can leave this server running while making changes to the docs. You can open
# a new terminal and re-run `genfiles.jl` and `make.jl` to see the changes.

