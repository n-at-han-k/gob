package main

import (
	"fmt"  // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"os"   // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
	"sort" // https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
)

// Each *.go file in this directory demonstrates one standard-library
// package. Run one demo at a time, e.g.:
//
//	go run . strings
//
// or list what's available with `go run .`.
var demos = map[string]func(){
	"archive":   runArchive,
	"bufio":     runBufio,
	"builtin":   runBuiltin,
	"bytes":     runBytes,
	"cmp":       runCmp,
	"compress":  runCompress,
	"container": runContainer,
	"context":   runContext,
	"database":  runDatabase,
	"debug":     runDebug,
	"embed":     runEmbed,
	"errors":    runErrors,
	"expvar":    runExpvar,
	"flag":      runFlag,
	"fmt":       runFmt,
	"go":        runGoTools,
	"hash":      runHash,
	"html":      runHTML,
	"image":     runImage,
	"index":     runIndex,
	"io":        runIO,
	"iter":      runIter,
	"log":       runLog,
	"maps":      runMaps,
	"math":      runMath,
	"mime":      runMime,
	"net":       runNet,
	"os":        runOS,
	"path":      runPath,
	"plugin":    runPlugin,
	"reflect":   runReflect,
	"regexp":    runRegexp,
	"runtime":   runRuntime,
	"simd":      runSimd,
	"slices":    runSlices,
	"sort":      runSort,
	"strconv":   runStrconv,
	"strings":   runStrings,
	"structs":   runStructs,
	"sync":      runSync,
	"syscall":   runSyscall,
	"testing":   runTesting,
	"text":      runText,
	"time":      runTime,
	"unicode":   runUnicode,
	"unique":    runUnique,
	"unsafe":    runUnsafe,
	"weak":      runWeak,
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("usage: go run . <package>")
		fmt.Println("available demos:")
		names := make([]string, 0, len(demos))
		for k := range demos {
			names = append(names, k)
		}
		sort.Strings(names)
		for _, n := range names {
			fmt.Println("  ", n)
		}
		return
	}
	demo, ok := demos[os.Args[1]]
	if !ok {
		fmt.Println("unknown demo:", os.Args[1])
		os.Exit(1)
	}
	demo()
}
