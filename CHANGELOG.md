# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `gob fmt`, `gob vet` and `gob transpile` take a directory as well as a file, expanding it to every `.gob` file under it, so `gob vet src packages` checks a whole tree in one pass. With no path at all they read the current directory
- `gob transpile` accepts several inputs and mirrors a source tree into an output directory: `gob transpile src -o ./build` writes `src/journal/table.gob` to `build/journal/table.go`. Without `--output` each file writes to its own `.go` sibling

### Changed

- `gob fmt` writes in place and no longer takes `--write`; formatting is what the command is for, the way `gofmt -w` and `go fmt` behave. Reading stdin still prints to stdout, and a file whose formatting is already correct is left untouched
- `--output` names a directory when the input is a directory or more than one file, and a file when the input is a single file

### Fixed

- a declaration written between two `const` or two `var` declarations was silently dropped, along with its methods. Grouping adjacent declarations into one parenthesised block took the whole span from the first such declaration in the file to the last and discarded everything in it that was not a declaration of that kind, so a `type` and its methods sitting between two groups of constants never reached the output. Only genuinely adjacent declarations are grouped now, and constants on either side of an intervening declaration stay in separate blocks
- `Gob/CollectionLiteral` no longer reports the result list of a func type. `Proc[string, [int, error]]` is the documented spelling for `func(string) (int, error)`, but the array literal holding the results was read as an untyped collection, so the documented form could not vet clean

## [1.4.0] - 2026-11-27

### Added

- Interfaces: a `module` nested inside the package module emits a Go interface, one method per `def`, with parameter and result types read from the signature comment — `def Stat(filePath) # (string) -> (FileStat, error)` becomes `Stat(filePath string) (FileStat, error)`. `include Greeter` in a class body names the interface and emits nothing, Go satisfying it implicitly
- Empty struct type: `Struct`, `Class`, `Struct[]`, `Class[]`, and `struct` in a type position emit Go `struct{}`, so `var :x, Struct[]` gives `var x struct{}` and `Class.new(Array[struct, 1])` gives `type armFits [1]struct{}`
- Struct tags on `attr_accessor` fields: ``attr_accessor :Name, string # `json:"name"` `` emits ``Name string `json:"name"` ``. The tag must sit on the same line as the field; one on the line above is still ignored there
- `Gob::RubyParser`, a `SyntaxTree::Parser` subclass that homes a comment on the innermost node at the edge of an argument list rather than on the list itself. `Gob.transpile`, `Gob.transpile_to_go`, `Gob::Transpilation::Context` and `Gob::Validation::Rules` all parse through `Gob::RubyParser.parse` instead of `SyntaxTree.parse`
- a standalone `gob` binary, compiled ahead of time by spinel and needing no Ruby on the target machine; built by the flake's `packages.gob` and attached to each release

### Changed

- the first `module` in a file names the package; every `module` after it declares an interface rather than renaming the package
- a single unnamed result is no longer parenthesized: `func f() error` and `func(int) bool` rather than `func f() (error)` and `func(int) (bool)`. Named results and multiple results keep their parentheses
- `gob fmt` no longer moves an inline struct tag onto the line above its field, and `Gob::Validation::Rules::StructTagPosition` no longer reports one; both placements now emit the tag

### Fixed

- the struct tag on the last field of a multi-line `Struct.new(...)` was homed on the argument list rather than on the field, and was dropped from the emitted struct

## [1.3.0] - 2026-11-27

### Added

- Unary bitwise NOT: `~x` emits Go `^x`
- Bit clear operator: `a &! b` emits Go `a &^ b`
- Channel receive syntax: `ch.<<` emits Go `<-ch`; `v, ok = ch.<<` emits `v, ok := <-ch`
- Channel send syntax: `ch.<< v` / `ch.<<(v)` emit Go `ch <- v`
- Channel arrow syntax: `←ch` receives and `ch ← v` sends

### Changed

- Channel receive now uses `ch.<<` instead of `~ch`
- `~` is no longer channel receive; it is now unary bitwise NOT (`^` in Go)
- `ch << v` remains supported as a channel send

## [1.2.3] - 2026-11-27

### Added

- `Proc[...]` type declarations now support a final array literal for return types, e.g. `Proc[[bool]]`, `Proc[int, [bool]]`, `Proc[int, [bool, error]]`
- Type-form `.call` casts: `@@T.(x)` and `Array[T].(x)` / `Hash[K,V].(x)` / `Chan[T].(x)` emit Go type conversions

### Changed

- `Array[byte].new(x)` / `Array[rune].new(x)` are no longer special-cased as conversions; use `Array[byte].(x)` / `Array[rune].(x)` for `[]byte(x)` / `[]rune(x)`

## [1.2.1] - 2026-11-26

### Fixed

- `Gob::Transpilation::Runner#parse_signature_comment` now parses signature comment shapes correctly, including func-typed params/returns and void `-> ()` returns

## [1.2.0] - 2026-11-26

### Changed

- methods now take a pointer receiver by default; `protected def` declares a value receiver instead. This replaces the `def self.Method` rule from 1.1.1

### Removed

- removed the `gob init` command

## [1.1.4] - 2026-11-26

### Changed

- `gob build`, `gob run`, and `gob transpile` now announce each stage of the pipeline — `fmt`, `vet`, `transpile`, `gofmt` — on stderr through `Gob::Reporter`, so a failure names the stage it came from
- `Gob::Go::Runner` now runs the Go toolchain with inherited streams and prints the command it runs; `go build` and `go run` output arrives as it is produced rather than after the process exits, and programs run by `gob run` inherit stdin

## [1.1.3] - 2026-11-26

### Added

- `gob init [MODULE]` now scaffolds `Gemfile`, `main.gob`, and `.gitignore`, merges existing project files, and writes `flake.nix` and `.envrc` with `--nix`

## [1.1.2] - 2026-11-26

### Added

- `gob init [MODULE]` delegates to `go mod init` to create a `go.mod` in the current directory

## [1.1.1] - 2026-11-26

### Added

- `gob fmt` now normalizes `go call(...)` to `go lambda { ... }.()` through `Gob::Validation::Rules::GoCall`
- `gob fmt` now moves struct tag comments before their fields through `Gob::Validation::Rules::StructTagPosition`

### Fixed

- `Gob::Transpilation::Runner` now emits pointer receivers for methods declared with `def self.Method`; use this form for mutating methods such as `UnmarshalText`

## [1.1.0] - 2026-11-26

### Added

- `gob completion --shell bash|zsh|fish` (`Gob::CLI#completion`) generates shell completion scripts

### Changed

- rewrote the compiler around `Gob::Transpilation::Runner`; `Gob.transpile` and `Gob.transpile_to_go` keep their existing signatures
- `gob fmt` now uses `Gob::Validation::Rules.autocorrect` to apply Gob's validation and layout rules

### Removed

- removed `Gob::Transpiler`, `Gob::Matcher`, `Gob.default_matcher`, `Gob::Go::DSL`, and `Gob::Transpilation::Rules`; use `Gob.transpile`, `Gob.transpile_to_go`, or `Gob::Transpilation::Runner` instead

## [1.0.0] - 2026-11-24

### Added

- initial release

[Unreleased]: https://github.com/n-at-han-k/gob/compare/v1.4.0...HEAD
[1.4.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.4.0
[1.3.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.3.0
[1.2.3]: https://github.com/n-at-han-k/gob/releases/tag/v1.2.3
[1.2.1]: https://github.com/n-at-han-k/gob/releases/tag/v1.2.1
[1.2.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.2.0
[1.1.4]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.4
[1.1.3]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.3
[1.1.2]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.2
[1.1.1]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.1
[1.1.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.0
[1.0.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.0.0
