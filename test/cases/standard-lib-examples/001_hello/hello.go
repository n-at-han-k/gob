// `package main` declares the file as belonging to the `main` package,
// which tells the Go compiler to build an executable program (rather than a library).
// Every Go executable must have exactly one `main` package containing a `main()` function,
// which is the program's entry point.
package main

// `import "fmt"` pulls in the [`fmt`](https://pkg.go.dev/fmt) package from Go's standard library,
// which provides formatted I/O functions (analogous to C's `printf`/`scanf`).
// It's needed here so we can call `fmt.Println` to write to standard output.
// Imported names are accessed via the package qualifier (`fmt.Println`), and unused imports are a compile error in Go.
import "fmt"

func main() {
	fmt.Println("Hello, gopher!")
}
