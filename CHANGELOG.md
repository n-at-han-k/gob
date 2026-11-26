# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/n-at-han-k/gob/compare/v1.1.3...HEAD
[1.1.3]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.3
[1.1.2]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.2
[1.1.1]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.1
[1.1.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.1.0
[1.0.0]: https://github.com/n-at-han-k/gob/releases/tag/v1.0.0
