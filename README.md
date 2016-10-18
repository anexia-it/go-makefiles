go-makefiles
===

This repository contains a set of Makefiles that we at (ANEXIA)[https://www.anexia-it.com] are using internally and believe that could be useful for other
developers as well.

A single, empty, Go package is contained within this directory, so these
Makefiles can easily be integrated into projects that are making use
of Go dependency managers, such as `glide` or `Godeps`.

Examples
---

Examples on how to use these Makefiles can be found in the (examples)[examples/]
directory of this repository.

For most projects the (auto)[examples/auto/Makefile] is most likely sufficient.

Suggested integration
---

This is a suggestion only which is based on our own experiences.
Internally we are adding this repository/package to the corresponding
project's vendor folder and are then using the relative path (ie. `vendor/github.com/anexia-it/go-makefiles/`) for including the Makefiles into our
project's Makefiles.

In order to keep dependency managers from removing the 'unused' package, we
usually create a single source file which imports the empty Go package
contained within go-makefiles.

Contributing
---

Contributions are always very welcome, including both bug reports and feature
enhancements.