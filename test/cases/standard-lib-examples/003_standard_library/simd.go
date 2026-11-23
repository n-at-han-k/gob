package main

import "fmt" // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.

// simd is an experimental package for explicit SIMD vector operations.
// It is not part of the stable API — availability varies by Go version
// and target architecture, and it usually requires GOEXPERIMENT=simd.
//
// A typical usage (subject to change) would look like:
//
//	import "simd"
//
//	var a, b simd.Int32x8
//	a = simd.LoadInt32x8Slice(xs)
//	b = simd.LoadInt32x8Slice(ys)
//	sum := simd.AddInt32x8(a, b)
//	sum.StoreInt32x8Slice(out)
//
// For portable code, prefer plain loops — the compiler auto-vectorises
// many of them without you having to touch simd directly.
func runSimd() {
	fmt.Println("simd is experimental; see comments for usage sketch")
}
