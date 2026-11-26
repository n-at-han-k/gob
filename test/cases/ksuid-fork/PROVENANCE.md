# Provenance

This directory is an unmodified clone of a real third-party Go project, kept as
a transpilation case: it is large and realistic enough to be a genuine test of
whether Gob is correct, which the single-concept examples are not.

- Upstream: https://github.com/segmentio/ksuid
- Commit: d33724947fcfba7949906c2b1821e96a1c8d06e7
- License: MIT (see LICENSE.md, retained from upstream)

The `.go` files are upstream's and are **not** hand-written goldens: they
compile, their own `go test ./...` passes, and `go run ./cmd/ksuid` prints a
KSUID. That makes them a golden set we know is correct, rather than one we
asserted. The `.gob` files beside them are the port; `bin/test` diffs what the
transpiler emits for each `.gob` against the upstream `.go` next to it.

Do not edit the `.go` files. If the emitted Go differs, the `.gob` or the
transpiler is wrong.
