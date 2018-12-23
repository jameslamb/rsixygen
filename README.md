
# rsixygen

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jameslamb/rsixygen?branch=master&svg=true)](https://ci.appveyor.com/project/jameslamb/rsixygen)

There is [no built-in support for R6](https://github.com/klutometis/roxygen/issues/306) in `roxygen2`. 

This package is experimental, and implements a standard proposed by @cwschultz88 for documenting these objects.

To be clear, it does NOT automatically generate full Roxygen docs the way that `roxygen2::roxygenize` does. Instead, it dumps Roxygen skeletons to a directory of files. You will still have to do some manual work after this, but the package cuts down on a LOT of copy-pasting, indentation fixes, and general sadness around missing curly braces.

## Installation

This package is not yet on CRAN. For now, just install from Github.

```
devtools::install_github('jameslamb/rsixygen')
```

## Examples

All you have to do is this:

```
rsixygen::document_package("lightgbm", "some_docs")
```

That call will create a set of `.R` files (one per R6 class) in a new directory called `some_docs/`.

If you don't want to deal with the entire package, you can target an individual object:

```
rsixygen::document_class(lightgbm:::Booster)
```

I hope you find this useful. PRs are welcome!
