# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/n-at-han-k/gob/compare/v1.1.4...HEAD
[1.1.4]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.4
[1.1.3]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.3
[1.1.2]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.2
[1.1.1]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.1
[1.1.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.0
[1.0.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.0.0
