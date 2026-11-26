package main

import (
	"fmt"
	"os"
	"sort"
)

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
