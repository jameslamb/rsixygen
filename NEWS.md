# rsixygen 0.1.1

## Features

### Better handling of constructor
- As of [eb4a06](https://github.com/jameslamb/rsixygen/commit/eb4a065503d37c569c1a3f9eba77856378b5677d), there are no longer be duplicate entries for `new()` and `initialize()` with mismatched function signatures.

## Bugfixes

### Weird constructor signatures no longer cause weird docs!
- As of [da9381e](https://github.com/jameslamb/rsixygen/commit/73a13fd05d949a21c084d0b45f10fdfdde6f4310), method signatures will no longer include attribute information like `srcref` stuff that can sometimes get attached to expressions. This was accomplished with regex so you know it isn't at all brittle or horrible.
